README.md

# Validation
## Validate JSON syntax
node -e "console.log(JSON.parse(require('fs').readFileSync('vercel.json', 'utf8')))"
If no errors, your JSON is valid!


# Deployment
## First deployment (creates project)
vercel

## Production deployment
vercel --prod

## View deployment logs
vercel logs

## List all deployments
vercel ls
