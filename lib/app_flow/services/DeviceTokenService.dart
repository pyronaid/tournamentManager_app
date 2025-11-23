import 'dart:io';

import 'package:pocketbase/pocketbase.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:tournamentmanager/backend/schema/device_tokens_record.dart';

class DeviceTokenService {
  final PocketBase _pb;
  final FirebaseMessaging _fcm;

  DeviceTokenService(this._pb) : _fcm = FirebaseMessaging.instance;

  /// Save or update the device token for the current user
  Future<void> saveDeviceToken() async {
    try {
      // Check if user is authenticated
      if (!_pb.authStore.isValid) {
        debugPrint('[DeviceTokenService] User not authenticated, skipping token save');
        return;
      }

      final userId = _pb.authStore.record?.id;
      if (userId == null) {
        debugPrint('[DeviceTokenService] User ID is null');
        return;
      }

      // Get the FCM token
      final token = await _fcm.getToken();
      if (token == null) {
        debugPrint('[DeviceTokenService] Failed to get FCM token');
        return;
      }

      debugPrint('[DeviceTokenService] Got FCM token: ${token.substring(0, 20)}...');

      // Get device information
      final platform = Platform.isAndroid ? 'android' : 'ios';

      // Check if token already exists for this user and device
      final existingTokens = await DeviceTokensRecord.getDocumentsOnce(
          _pb, '${DeviceTokensRecord.idUserFieldName} = "$userId" && ${DeviceTokensRecord.fcmTokenFieldName} = "$token"');

      if (existingTokens.isEmpty) {
        // Create new token record
        await DeviceTokensRecord.createDeviceToken(_pb, {
          DeviceTokensRecord.idUserFieldName: userId,
          DeviceTokensRecord.fcmTokenFieldName: token,
          DeviceTokensRecord.deviceTypeFieldName: getDeviceTypeByName(platform).name,
          DeviceTokensRecord.lastActiveFieldName: DateTime.now().toString(),
        });
        debugPrint('Device token saved successfully');
      } else {
        // Update existing token to ensure it's active
        final existingToken = existingTokens.first;
        await DeviceTokensRecord.updateField(_pb, existingToken.uid, DeviceTokensRecord.lastActiveFieldName, DateTime.now());
        debugPrint('Device token updated successfully');
      }
    } catch (e) {
      debugPrint('Error saving device token: $e');
      // Don't throw - we don't want to break the login flow
    }
  }

  Future<void> removeDeviceToken() async {
    try {
      final token = await _fcm.getToken();
      if (token == null) return;

      final userId = _pb.authStore.record?.id;
      if (userId == null) return;

      // Find and deactivate the token instead of deleting
      // (keeps history for analytics)
      final existingTokens = await DeviceTokensRecord.getDocumentsOnce(
          _pb, '${DeviceTokensRecord.idUserFieldName} = "$userId" && ${DeviceTokensRecord.fcmTokenFieldName} = "$token"');

      for (final tokenRecord in existingTokens) {
        await DeviceTokensRecord.deleteDeviceToken(_pb, tokenRecord.uid);
      }
      debugPrint('Device token removed successfully');
    } catch (e) {
      debugPrint('Error removing device token: $e');
    }
  }

  /// Listen for token refresh and update PocketBase
  void listenForTokenRefresh() {
    _fcm.onTokenRefresh.listen((newToken) async {
      debugPrint('FCM token refreshed: ${newToken.substring(0, 20)}...');
      await saveDeviceToken();
    });
  }
}