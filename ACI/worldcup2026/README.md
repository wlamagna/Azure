## This project is an Azure Container instance with an API that returns randomly a football player name and nationality and the football players are all the players of the WorldCup 2026.  

* The list of football players and nationality was created also by me, i could not find a dataset in the web so i created it from scratch.

* Diagram
!(diagram.png)

### It is Saturday, no wind outside, then it is a good moment to practice some of the skills acquired on the az-305 and az-104 and play today with some continers.

#### I recommend setting a python virtual environment, you can just use the cloudshell.  But it is not really required, only some tip.
```
python -m venv .venv
```
#### Installing some required packages
```
pip install azure-keyvault
pip install azure-cosmos
pip install azure-identity
```

#### Setting some variables
```
CN="playerone"
RG="test01"
COSMOSDB="test01account"
ACR="acrcordoba"
KVNAME="kvcup2026"

az group create -g $RG --location westus
```

#### Create the cosmos DB, then obtain the Keys and store it in the KV (created next)
```
az cosmosdb create -n "$COSMOSDB" \
-g $RG --enable-free-tier true \
--locations regionName="West US" \
--default-consistency-level "Session"
```

#### Create the Azure Container Registry we will use to store the image and also to build the Dockerfile
#### In Access keys > Admin user (enable) and copy the password (you will need it later)
```
az acr create --resource-group $RG --name acr2026 --sku Basic
```
### Prepare Key Vault
#### Set the key for the cosmos DB into the keyvault.
```
az keyvault create --name "$KVNAME" \
--resource-gropup $RG --sku "standard"
```
#### Put in the keyvault the secret for the CosmosDb: cosmosdb and the secret (from previously when you created the Resource)


### Load the data into cosmos db
#### This step is to populate date into the Cosmos DB, we are loading the players from the world cup 2026
```
./cosmos_load.py
```
#### This tool is to test that it is working:
```
./cosmos_read.py
```
#### Create the Docker image (from azure CLI) - no need to install anything more.  The Dockerfile is in the directory [Dockerfile ](https://github.com/wlamagna/Azure/tree/main/ACI/worldcup2026/container)
```
az acr build --image $ACR.azurecr.io/$CN:v1` \
--registry "$ACR" --file Dockerfile .
```
#### It will ask for a user and password, it is the ACR name and the password from the ACR.
#### Now create the instance out of the image, and with an identity.
```
az container create --resource-group $RG --name $CN \
--image $ACR.azurecr.io/$CN:v1 \
--dns-name-label $CN --ports 5000 --os-type linux --memory 2 --cpu 1 \
--locaion westus2 --assign-identity
```
#### It uses a system assigned identity, we need to give KV the permission to this identity to read secrets.
#### Visit the url and the API !
```
http://$CN.westus2.azurecontainer.io:5000
```

#### To obtain the url:
```
az container show --resource-group $RG --name $CN --query "ipAddress.fqdn"
```

#### Cleanup to avoid charges:
```
az group delete -g $RG --yes
```
