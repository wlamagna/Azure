cd terraform
terraform init
terraform apply -var="prefix=wl-stg" \
  -var="basic_auth_user=staging" \
  -var="basic_auth_hash=$2a$14$exampleBcryptHashFromCaddyTool..."

# Get a bcrypt hash for your password (don’t use plaintext):

docker run --rm caddy caddy hash-password -p 'your-staging-password'

Use the resulting hash as basic_auth_hash and in .env.sample below.
