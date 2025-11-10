README.md

# Validate JSON syntax
node -e "console.log(JSON.parse(require('fs').readFileSync('vercel.json', 'utf8')))"

# If no errors, your JSON is valid!
