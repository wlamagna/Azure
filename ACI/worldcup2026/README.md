### This project is an Azure Container instance with an API that returns randomly a football player name and nationality and the football players are all the players of the WorldCup 2026.  The purpose is to experiment and face real problems, look up to where i can go with my subscription.

* The list of football players and nationality was created also by me, i could not find a dataset in the web so i created it from scratch [WorldCup2026Players](tools/players.csv)

* Diagram

![Topology](diagram.png)



#### Step1. Setting some variables
```
RGNAME="test01"
REGION="eastus"
VMNAME="vm01"
CONTAINERNAME="playerone"
COSMOSDBNAME="test01account"
ACREGISTRY="acrcordoba"
KVNAME="kvwc2026"
EMAIL="...#EXT#@SOMETHING.onmicrosoft.com"
SUBID="YOUR_SUBSCRIPTION_ID"

echo -n "Creating Resource Group "
az group create -g $RGNAME --location $REGION -o none
if [ $? == 0 ]; then echo "[ok]"; else echo "[x]"; fi;
```

#### For this you will need to have the following namespaces registered
```
az provider register --namespace Microsoft.DocumentDB
az provider register --namespace Microsoft.ContainerRegistry
az provider register --namespace Microsoft.KeyVault
az provider register --namespace Microsoft.ContainerInstance
```

#### Step2. Create the cosmos DB, then obtain the Keys and store it in the KV (created next)
```
echo -n "Creating the cosmos DB "
az cosmosdb create -n "$COSMOSDBNAME" -g $RGNAME --enable-free-tier true \
--locations regionName="West US" --default-consistency-level "Session" -o none 2>/dev/null
if [ $? == 0 ]; then echo "[ok]"; else echo "[x]"; fi;
```

#### Step 3. Create the Azure Container Registry we will use to store the image and also to build the Dockerfile
#### In Access keys > Admin user (enable) and copy the password (you will need it later)
```
echo -n "Creating Azure Container Registry "
az acr create --resource-group $RGNAME --name $ACREGISTRY --sku Basic -o none 2>/dev/null
if [ $? == 0 ]; then echo "[ok]"; else echo "[x]"; fi;
```

### Step 4. Prepare Key Vault
#### Set the key for the cosmos DB into the keyvault.
#### And give the managed entity access to the keyvault to read the secret
```
echo -n "Creating Azure Key Vault "
az keyvault create --name "$KVNAME" --resource-group $RGNAME --sku "standard" -o none 2>/dev/null
if [ $? == 0 ]; then echo "[ok]"; else echo "[x]"; fi;

echo -n "Enabling RBAC to Key Vault "
az keyvault update --name "$KVNAME" --resource-group "$RGNAME" --enable-rbac-authorization true -o none 2>/dev/null
if [ $? == 0 ]; then echo "[ok]"; else echo "[x]"; fi;
```

#### Put in the keyvault the secret for the CosmosDb: cosmosdb and the secret (from previously when you created the Resource)
```
echo -n "Assigning the role Key Vault Secrets Officer "
az role assignment create --role "Key Vault Secrets Officer" --assignee "$EMAIL" \
--scope "/subscriptions/$SUBID/resourceGroups/$RGNAME/providers/Microsoft.KeyVault/vaults/$KVNAME" -o none 2>/dev/null
if [ $? == 0 ]; then echo "[ok]"; else echo "[x]"; fi;

KEY=`az cosmosdb keys list --name $COSMOSDBNAME -g $RGNAME | jq .primaryMasterKey | sed 's/"//g'`

echo -n "Setting secret to KeyVault "
az keyvault secret set --vault-name "$KVNAME" --name "cosmosdb" --value "$KEY" -o none 2>/tmp/err
if [ $? == 0 ]; then echo "[ok]"; else echo "[x]"; fi;
```

### Load the data into cosmos db
#### This step is to populate date into the Cosmos DB, we are loading the players from the world cup 2026
#### Download the cosmos_load.py, edit it and set the Key Vault name that you used
```
echo "Download initialization scripts"
wget https://raw.githubusercontent.com/wlamagna/Azure/refs/heads/main/ACI/worldcup2026/tools/cosmos_load.py
wget https://raw.githubusercontent.com/wlamagna/Azure/refs/heads/main/ACI/worldcup2026/tools/cosmos_read.py
wget https://raw.githubusercontent.com/wlamagna/Azure/refs/heads/main/ACI/worldcup2026/tools/players.csv
chmod +x cosmos_load.py
python -m venv .venv
source .venv/bin/activate
pip install azure-keyvault
pip install azure-cosmos
pip install azure-identity

./cosmos_load.py
```
#### This tool is to test that it is working:
```
./cosmos_read.py
```

#### Step 5. Create the Docker image (from azure CLI)
#### Up to this point the instructions should be fine for an Azure Student Account, but the next step works for an upgraded account only.  This only works in a NonStudent account.  Here is a link to an alternative solution where we deploy quickly a Linux VM with Docker and we create the Docker Image from there and upload it to the ACRegistry.  Link to VM creation instructions: [Linux+Docker](https://github.com/wlamagna/Azure/tree/main/Compute)
```
az acr build --image $ACR.azurecr.io/$CN:v1 --registry "$ACR" --file Dockerfile .
```
#### Step 3. It will ask for a user and password, it is the ACR name and the password from the ACR.
#### Now create the instance out of the image, and with an identity.
```
az container create --resource-group $RGNAME --name newcontainer \
--image $ACREGISTRY.azurecr.io/$CONTAINERNAME:v1 \
--ports 5000 --os-type linux --memory 2 --cpu 1 --location $REGION --registry-username acrcordoba \
--registry-password "$ACR_KEY" \
--assign-identity --dns-name-label $CONTAINERNAME-$RANDOM
```
#### It uses a system assigned identity, we need to give KV the permission to this identity to read secrets.
#### Finally:
#### Visit the url and the API !
```
http://$CN.westus2.azurecontainer.io:5000
```

```
az container show --resource-group $RG --name $CN --query "ipAddress.fqdn"
```

#### Cleanup to avoid charges:
```
az group delete -g $RG --yes
```


