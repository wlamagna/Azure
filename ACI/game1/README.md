# This project is an Azure Container instance with a snake game.  It is in progress, the game was just vibe coded (i won't) lie at this point in life ! but it is nice, i found interesting putting it in a container and publishing it.  It is in progress, not yet available here but soon.

```
az group create -g group1 --location eastus
az acr create -g group1 --name myacr --sku Basic
```
# Check it:
```
az acr list -o table
```
# Build the image with the ACR that was just created
```
az acr build --image myacr.azurecr.io/game1:v1 --registry myacr --file Dockerfile .
```
# Portal > ACR > Repositories: Here appears the new image

# Get the key from Portal > ACR > Settings > Access keys > Enable Admin user and copy paste the key.

az container create -g group_instances \
--name firstgame --image acrcordoba.azurecr.io/game1:v1 \
--ip-address Public --dns-name-label firstgame \
--ports 5000 --os-type linux --memory 2 --cpu 1 --zone 1 --location eastus

az container show -g group_instances --name firstgame --query "ipAddress.fqdn"
"firstgame.eastus.azurecontainer.io"




