const express = require('express');
const { initializeApp, getApps, getApp } = require('firebase-admin/app');
const { getMessaging } = require('firebase-admin/messaging');
const { credential } = require('firebase-admin');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const helmet = require('helmet');
const crypto = require('crypto');

const app = express();
const PORT = process.env.PORT || 3000;

// Global state management
let firebaseApp = null;
let isFirebaseReady = false;
let firebaseInitError = null;

// ============================================================================
// SECURITY MIDDLEWARE
// ============================================================================

// Security headers using Helmet
app.use(helmet({
  crossOriginEmbedderPolicy: false,
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"]
    }
  }
}));

// CORS configuration - restrict to your PocketBase domain
const allowedOrigins = process.env.ALLOWED_ORIGINS 
  ? process.env.ALLOWED_ORIGINS.split(',') 
  : ['http://localhost:8090'];

app.use(cors({
  origin: (origin, callback) => {
    // Allow requests with no origin (like mobile apps or curl requests)
    if (!origin) return callback(null, true);
    
    if (allowedOrigins.indexOf(origin) !== -1) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true
}));

app.use(express.json({ limit: '1mb' }));

// Global rate limiter - prevents DDoS attacks
const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Max 100 requests per IP per window
  message: {
    success: false,
    error: 'Too many requests from this IP, please try again later.',
    code: 'RATE_LIMIT_EXCEEDED'
  },
  standardHeaders: true,
  legacyHeaders: false
});

// Stricter rate limiter for notification endpoints
const notificationLimiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 minute
  max: 10, // Max 10 notification requests per minute
  message: {
    success: false,
    error: 'Too many notification requests, please try again later.',
    code: 'NOTIFICATION_RATE_LIMIT_EXCEEDED'
  },
  standardHeaders: true,
  legacyHeaders: false
});

app.use(globalLimiter);

// ============================================================================
// FIREBASE INITIALIZATION
// ============================================================================

/**
 * Initialize Firebase Admin SDK v13
 * Handles private key formatting and environment variable parsing
 */
function initializeFirebaseV13() {
  try {
    // Check if already initialized
    const existingApps = getApps();
    if (existingApps.length > 0) {
      console.log('✅ Firebase already initialized');
      firebaseApp = getApp();
      isFirebaseReady = true;
      return true;
    }

    // Validate required environment variables
    const requiredEnvVars = [
      'FIREBASE_PROJECT_ID',
      'FIREBASE_PRIVATE_KEY',
      'FIREBASE_CLIENT_EMAIL'
    ];

    for (const envVar of requiredEnvVars) {
      if (!process.env[envVar]) {
        throw new Error(`Missing required environment variable: ${envVar}`);
      }
    }

    // Process private key - handle different formats
    let privateKey = process.env.FIREBASE_PRIVATE_KEY;
    
    // Remove surrounding quotes if present
    if (privateKey.startsWith('"') && privateKey.endsWith('"')) {
      privateKey = privateKey.slice(1, -1);
    }
    
    // Replace escaped newlines with actual newlines
    privateKey = privateKey
      .replace(/\\n/g, '\n')
      .replace(/\n\s+/g, '\n')
      .trim();

    // Validate private key format
    if (!privateKey.includes('BEGIN PRIVATE KEY')) {
      throw new Error('Invalid private key format');
    }

    // Create service account credential object
    const serviceAccount = {
      type: "service_account",
      project_id: process.env.FIREBASE_PROJECT_ID,
      private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID || 'default',
      private_key: privateKey,
      client_email: process.env.FIREBASE_CLIENT_EMAIL,
      client_id: process.env.FIREBASE_CLIENT_ID || '',
      auth_uri: "https://accounts.google.com/o/oauth2/auth",
      token_uri: "https://oauth2.googleapis.com/token",
      auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs"
    };

    // Initialize Firebase Admin SDK
    firebaseApp = initializeApp({
      credential: credential.cert(serviceAccount),
      projectId: process.env.FIREBASE_PROJECT_ID
    });

    console.log('✅ Firebase Admin SDK v13 initialized successfully');
    console.log(`📊 Project ID: ${process.env.FIREBASE_PROJECT_ID}`);
    
    isFirebaseReady = true;
    return true;

  } catch (error) {
    console.error('❌ Firebase v13 initialization failed:', error.message);
    console.error('Stack trace:', error.stack);
    firebaseInitError = error.message;
    isFirebaseReady = false;
    return false;
  }
}

// Initialize Firebase on startup
initializeFirebaseV13();

// ============================================================================
// AUTHENTICATION MIDDLEWARE
// ============================================================================

/**
 * Validates API key using timing-safe comparison to prevent timing attacks
 */
const validateApiKey = (req, res, next) => {
  const apiKey = req.headers['x-api-key'];
  const expectedApiKey = process.env.API_SECRET_KEY;

  if (!expectedApiKey) {
    console.error('❌ API_SECRET_KEY not configured');
    return res.status(500).json({
      success: false,
      error: 'Server configuration error',
      code: 'MISSING_API_KEY_CONFIG'
    });
  }

  if (!apiKey) {
    return res.status(401).json({
      success: false,
      error: 'API key required',
      code: 'MISSING_API_KEY',
      hint: 'Include X-API-Key header in your request'
    });
  }

  try {
    // Use timing-safe comparison to prevent timing attacks
    const expectedBuffer = Buffer.from(expectedApiKey);
    const providedBuffer = Buffer.from(apiKey);

    if (expectedBuffer.length !== providedBuffer.length ||
        !crypto.timingSafeEqual(expectedBuffer, providedBuffer)) {
      return res.status(401).json({
        success: false,
        error: 'Invalid API key',
        code: 'INVALID_API_KEY'
      });
    }

    next();
  } catch (error) {
    console.error('Error in API key validation:', error);
    return res.status(500).json({
      success: false,
      error: 'Authentication error',
      code: 'AUTH_ERROR'
    });
  }
};

// ============================================================================
// INPUT VALIDATION MIDDLEWARE
// ============================================================================

/**
 * Validates notification request payload
 */
const validateNotificationInput = (req, res, next) => {
  const { tokens, title, body, data, options } = req.body;

  // Validate tokens array
  if (!tokens || !Array.isArray(tokens) || tokens.length === 0) {
    return res.status(400).json({
      success: false,
      error: 'tokens must be a non-empty array',
      code: 'INVALID_TOKENS'
    });
  }

  // Limit batch size to prevent abuse
  if (tokens.length > 1000) {
    return res.status(400).json({
      success: false,
      error: 'tokens array too large (max 1000 tokens per request)',
      code: 'BATCH_SIZE_EXCEEDED',
      hint: 'Split your request into smaller batches'
    });
  }

  // Validate each token format
  for (const token of tokens) {
    if (typeof token !== 'string' || token.length < 10 || token.length > 200) {
      return res.status(400).json({
        success: false,
        error: 'Invalid token format detected',
        code: 'INVALID_TOKEN_FORMAT',
        hint: 'FCM tokens should be strings between 10-200 characters'
      });
    }
  }

  // Validate title
  if (!title || typeof title !== 'string' || title.trim().length === 0) {
    return res.status(400).json({
      success: false,
      error: 'title is required and must be a non-empty string',
      code: 'INVALID_TITLE'
    });
  }

  if (title.length > 100) {
    return res.status(400).json({
      success: false,
      error: 'title must be 100 characters or less',
      code: 'TITLE_TOO_LONG'
    });
  }

  // Validate body
  if (!body || typeof body !== 'string' || body.trim().length === 0) {
    return res.status(400).json({
      success: false,
      error: 'body is required and must be a non-empty string',
      code: 'INVALID_BODY'
    });
  }

  if (body.length > 500) {
    return res.status(400).json({
      success: false,
      error: 'body must be 500 characters or less',
      code: 'BODY_TOO_LONG'
    });
  }

  // Validate data object (optional)
  if (data !== undefined && (typeof data !== 'object' || Array.isArray(data))) {
    return res.status(400).json({
      success: false,
      error: 'data must be an object',
      code: 'INVALID_DATA'
    });
  }

  // Validate options object (optional)
  if (options !== undefined && (typeof options !== 'object' || Array.isArray(options))) {
    return res.status(400).json({
      success: false,
      error: 'options must be an object',
      code: 'INVALID_OPTIONS'
    });
  }

  next();
};

// ============================================================================
// API ENDPOINTS
// ============================================================================

/**
 * Health check endpoint - useful for monitoring
 */
app.get('/health', (req, res) => {
  const apps = getApps();
  const health = {
    status: isFirebaseReady ? 'healthy' : 'degraded',
    timestamp: new Date().toISOString(),
    firebase: {
      ready: isFirebaseReady,
      apps: apps.length,
      error: firebaseInitError
    },
    environment: process.env.NODE_ENV || 'development',
    uptime: process.uptime()
  };

  const statusCode = isFirebaseReady ? 200 : 503;
  res.status(statusCode).json(health);
});

/**
 * Send push notification endpoint
 * POST /send-notification
 * 
 * Request body:
 * {
 *   "tokens": ["token1", "token2", ...],
 *   "title": "Notification title",
 *   "body": "Notification body",
 *   "data": { "key": "value" }, // optional
 *   "options": { // optional
 *     "channelId": "default",
 *     "sound": "default",
 *     "badge": 1
 *   }
 * }
 */
app.post('/send-notification',
  validateApiKey,
  notificationLimiter,
  validateNotificationInput,
  async (req, res) => {
    // Check Firebase availability
    if (!isFirebaseReady || !firebaseApp) {
      return res.status(503).json({
        success: false,
        error: 'Firebase service unavailable',
        code: 'FIREBASE_ERROR',
        details: firebaseInitError
      });
    }

    const { tokens, title, body: messageBody, data = {}, options = {} } = req.body;

    // Remove duplicate tokens for efficiency
    const uniqueTokens = [...new Set(tokens)];
    
    console.log(`📨 Processing notification request:`);
    console.log(`   - Tokens: ${uniqueTokens.length} (${tokens.length - uniqueTokens.length} duplicates removed)`);
    console.log(`   - Title: "${title}"`);
    console.log(`   - Body: "${messageBody.substring(0, 50)}${messageBody.length > 50 ? '...' : ''}"`);

    const results = [];
    let successCount = 0;
    let failureCount = 0;

    try {
      const messaging = getMessaging(firebaseApp);

      // Process tokens in batches (Firebase allows max 500 per batch)
      const batchSize = 500;
      const totalBatches = Math.ceil(uniqueTokens.length / batchSize);

      for (let i = 0; i < uniqueTokens.length; i += batchSize) {
        const batchNumber = Math.floor(i / batchSize) + 1;
        const batchTokens = uniqueTokens.slice(i, i + batchSize);

        console.log(`   Processing batch ${batchNumber}/${totalBatches} (${batchTokens.length} tokens)...`);

        // Convert all data values to strings (Firebase requirement)
        const stringifiedData = Object.keys(data).reduce((acc, key) => {
          acc[key] = String(data[key]);
          return acc;
        }, {});

        // Build the message payload
        const message = {
          tokens: batchTokens,
          notification: {
            title: title,
            body: messageBody
          },
          data: stringifiedData,
          android: {
            priority: 'high',
            notification: {
              channelId: options.channelId || 'default',
              sound: options.sound || 'default',
              clickAction: 'FLUTTER_NOTIFICATION_CLICK'
            }
          },
          apns: {
            payload: {
              aps: {
                alert: {
                  title: title,
                  body: messageBody
                },
                sound: options.sound || 'default',
                badge: options.badge || 1,
                contentAvailable: true
              }
            }
          },
          webpush: {
            notification: {
              title: title,
              body: messageBody,
              icon: options.icon || '/icon.png'
            }
          }
        };

        // Send to multiple devices using sendEachForMulticast
        const response = await messaging.sendEachForMulticast(message);

        successCount += response.successCount;
        failureCount += response.failureCount;

        // Track individual results for debugging
        response.responses.forEach((result, index) => {
          const tokenPreview = batchTokens[index].substring(0, 20) + "...";
          
          results.push({
            token: tokenPreview,
            success: result.success,
            messageId: result.messageId || null,
            error: result.error ? {
              code: result.error.code,
              message: result.error.message
            } : null
          });

          // Log failures for monitoring
          if (!result.success) {
            console.log(`   ❌ Failed to send to ${tokenPreview}: ${result.error?.message}`);
          }
        });
      }

      console.log(`✅ Notification sent: ${successCount} successful, ${failureCount} failed`);

      res.json({
        success: true,
        results: results,
        summary: {
          totalRequested: tokens.length,
          totalUnique: uniqueTokens.length,
          totalSent: successCount,
          totalFailed: failureCount,
          successRate: ((successCount / uniqueTokens.length) * 100).toFixed(2) + '%'
        },
        timestamp: new Date().toISOString()
      });

    } catch (error) {
      console.error('❌ Critical error in send-notification:', error);
      console.error('Stack trace:', error.stack);
      
      res.status(500).json({
        success: false,
        error: 'Failed to send notification',
        code: 'SEND_NOTIFICATION_ERROR',
        details: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  }
);

/**
 * Root endpoint - API information
 */
app.get('/', (req, res) => {
  res.json({
    service: 'Firebase Push Notification Service',
    version: '1.0.0',
    status: isFirebaseReady ? 'ready' : 'initializing',
    endpoints: {
      health: 'GET /health',
      sendNotification: 'POST /send-notification'
    },
    documentation: 'See README.md for API usage details'
  });
});

// ============================================================================
// ERROR HANDLING
// ============================================================================

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: 'Endpoint not found',
    code: 'NOT_FOUND',
    availableEndpoints: ['GET /', 'GET /health', 'POST /send-notification']
  });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('❌ Unhandled error:', err);
  
  res.status(err.status || 500).json({
    success: false,
    error: err.message || 'Internal server error',
    code: 'INTERNAL_ERROR'
  });
});

// ============================================================================
// SERVER STARTUP
// ============================================================================

app.listen(PORT, () => {
  console.log('╔════════════════════════════════════════════════════════╗');
  console.log('║   Firebase Push Notification Service                  ║');
  console.log('╚════════════════════════════════════════════════════════╝');
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🔥 Firebase Status: ${isFirebaseReady ? '✅ Ready' : '❌ Not Ready'}`);
  console.log('');
  console.log('Available endpoints:');
  console.log(`  - GET  http://localhost:${PORT}/`);
  console.log(`  - GET  http://localhost:${PORT}/health`);
  console.log(`  - POST http://localhost:${PORT}/send-notification`);
  console.log('');
  console.log('Press Ctrl+C to stop the server');
  console.log('════════════════════════════════════════════════════════');
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully...');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('\nSIGINT received, shutting down gracefully...');
  process.exit(0);
});
