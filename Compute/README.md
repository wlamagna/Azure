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
  --resource-group $RG \
  --name vm01 \
  --image Canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest \
  --admin-username azureuser \
  --generate-ssh-keys \
  --custom-data cloud-init.txt \
  --size Standard_D2s_v7
```

### Get your Public IP
```
az vm show \
  --resource-group $RG \
  --name vm01 \
  --show-details \
  --query publicIps \
  --output tsv
ssh azureuser@<YOUR_PUBLIC_IP>
```


apt-get -y update
apt-get install ca-certificates curl gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
usermod -aG docker azureuser