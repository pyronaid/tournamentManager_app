README.md

# Validation
## Validate JSON syntax
node -e "console.log(JSON.parse(require('fs').readFileSync('vercel.json', 'utf8')))"

If no errors, your JSON is valid!


# Test 
## Install dependencies
npm install
## Test the server
npm start

Visit http://localhost:3000/health


# Deployment
## Install Vercel CLI globally
npm install -g vercel
## First deployment (creates project)
vercel
## Login to Vercel
vercel login
## Production deployment
vercel --prod

Follow the prompts:
- Set up and deploy? Yes
- Which scope? Select your account
- Link to existing project? No
- Project name: firebase-notification-service (or your choice)
- Directory: ./ (current directory)
- Override settings? No
## View deployment logs
vercel logs
## List all deployments
vercel ls





