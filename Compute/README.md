#### Get required files
```
wget https://raw.githubusercontent.com/wlamagna/Azure/refs/heads/main/Compute/arms/newlinuxvm.params
wget https://raw.githubusercontent.com/wlamagna/Azure/refs/heads/main/Compute/arms/nic.arm
wget https://raw.githubusercontent.com/wlamagna/Azure/refs/heads/main/Compute/arms/newlinuxvm.arm
```

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

#### Creating the VM with Azure CLI


### 1. Create the Linux VM with the Cloud-Init script
az vm create \
  --resource-group $RG \
  --name MyDockerVM \
  --image Canonical:UbuntuServer:22_04-lts:latest \
  --admin-username azureuser \
  --generate-ssh-keys \
  --custom-data cloud-init.txt

### 2. Open port 80 (Optional - for web apps hosted in Docker)
az vm open-port \
  --resource-group $RG \
  --name MyDockerVM \
  --port 80 \
  --priority 1010



