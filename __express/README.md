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
## Deploy
vercel
## Production deployment
vercel --prod
## View deployment logs
vercel logs
## List all deployments
vercel ls





