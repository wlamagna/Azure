Create a Resource Group, ACR, App Service Plan, and a Linux Web App (plus a staging deployment slot).

Deploy your app using docker-compose (App Service supports this via linux_fx_version="COMPOSE|...").

Put a lightweight Caddy reverse proxy in front with HTTP Basic Auth guarding the whole site.

Pull images from Azure Container Registry (you’ll build & push from your GitHub repo).

Files included below:

terraform/main.tf (+ quick variables.tf)

docker-compose.yml (multi-container: proxy + api + web)

.env.sample

Caddyfile (basic auth + routing)
