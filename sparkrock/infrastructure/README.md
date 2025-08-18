Create a Resource Group, ACR, App Service Plan, and a Linux Web App (plus a staging deployment slot).
Deploy your app using docker-compose (App Service supports this via linux_fx_version="COMPOSE|...").
Put a lightweight Caddy reverse proxy in front with HTTP Basic Auth guarding the whole site.
Pull images from Azure Container Registry (you’ll build & push from your GitHub repo).

Files included below:
terraform/main.tf (+ quick variables.tf)
docker-compose.yml (multi-container: proxy + api + web)
.env.sample
Caddyfile (basic auth + routing)


📌 Build & push your images to ACR from your GitHub repo (two images: node-api, react-frontend) and tag them staging.
Example local build/push after az acr login:

ACR=yourprefixacr.azurecr.io

docker build -t $ACR/node-api:staging ./path/to/api

docker push $ACR/node-api:staging

docker build -t $ACR/react-frontend:staging ./path/to/web

docker push $ACR/react-frontend:staging


3) Caddyfile

Basic auth + simple routing: /{anything} -> web, /api/* -> api.

:80 {
  encode zstd gzip

  basicauth /* {
    {$BASIC_AUTH_USER} {$BASIC_AUTH_HASH}
  }

  @api path /api* /api/* 
  reverse_proxy @api api:3000

  reverse_proxy web:3000
}

* Change ports if your containers listen on different ports.

*The basic auth covers every path (/*). Tweak if you only want to guard certain paths.
