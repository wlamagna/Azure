#### Get required files
```
wget https://raw.githubusercontent.com/wlamagna/Azure/refs/heads/main/Compute/arms/newlinuxvm.params
wget https://raw.githubusercontent.com/wlamagna/Azure/refs/heads/main/Compute/arms/nic.arm
wget https://raw.githubusercontent.com/wlamagna/Azure/refs/heads/main/Compute/arms/newlinuxvm.arm
#### Creating the VM with Arm templates
### The strategy must be the following:
## 1. Create the Vnet because:
```
Vnet: Prod-VNet
'-- Subnect: default
       '--- NIC: vm01-nic
              '--- VM: vm01
```

#### First we create the virtual network required by the VM
az deployment group create --resource-group $RG --name newdeploy2025 --template-file arms/vnet.arm

#### Create the Network Interface for the VM
az deployment group create --resource-group $RG --name newdeploy2025v3 --template-file arms/nic.arm

#### Create a VM to Create the Docker files
az deployment group create --resource-group $RG --name newdeploy2025v2 \
--template-file arms/newlinuxvm.arm \
--parameters @arms/newlinuxvm.params

### 0. Create Resource Group
```
RG="test01"
az group create -g $RG --location eastus
```
### 1. Create the Linux VM with the Cloud-Init script
```
az vm list-skus --location eastus --size Standard_D --all --output table

az vm create \
  --resource-group $RGNAME \
  --name vm01 \
  --image Canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest \
  --admin-username azureuser \
  --generate-ssh-keys \
  --custom-data cloud-init.txt \
  --size Standard_D2s_v7
```

### Get your Public IP
```
az vm show --resource-group $RGNAME --name $VMNAME  --show-details \
--query publicIps --output tsv
ssh azureuser@<YOUR_PUBLIC_IP>
```

#### Inside the VM:
```
wget https://raw.githubusercontent.com/wlamagna/Azure/refs/heads/main/ACI/worldcup2026/container/Dockerfile
wget https://raw.githubusercontent.com/wlamagna/Azure/refs/heads/main/ACI/worldcup2026/container/app.py
wget https://raw.githubusercontent.com/wlamagna/Azure/refs/heads/main/ACI/worldcup2026/container/requirements.txt
docker build -t playerone:v1 .

docker tag playerone:v1 acrcordoba.azurecr.io/playerone:v1
docker login acrcordoba.azurecr.io --username acrcordoba --password "$ACRPASSWORD"
docker push acrcordoba.azurecr.io/playerone:v1
```

## exit the VM

az acr repository list -n $ACREGISTRY -o table

### Create the instance of the image
az container create --resource-group $RGNAME --name newcontainer \
--image $ACREGISTRY.azurecr.io/$CONTAINERNAME:v1 \
--ports 5000 --os-type linux --memory 2 --cpu 1 --location $REGION --registry-username acrcordoba \
--registry-password "8txHXSyoOUTN7UxB7zngm8LcEPB3k6O7JlouP5lVMMAW3sIjJEVeJQQJ99CGACYeBjFEqg7NAAACAZCR51dX" \
--assign-identity --dns-name-label $CONTAINERNAME-$RANDOM


8txHXSyoOUTN7UxB7zngm8LcEPB3k6O7JlouP5lVMMAW3sIjJEVeJQQJ99CGACYeBjFEqg7NAAACAZCR51dX
