#### First we create the virtual network required by the VM
az deployment group create --resource-group $RG --name newdeploy2025 \
--template-file arms/vnet.arm

#### Create the Network Interface for the VM
az deployment group create --resource-group $RG --name newdeploy2025 \
--template-file arms/nic.arm

#### Create a VM to Create the Docker files

az deployment group create --resource-group $RG --name newdeploy2025v2 \
--template-file arms/newlinuxvm.arm \
--parameters @arms/newlinuxvm.params


wget https://raw.githubusercontent.com/wlamagna/Azure/refs/heads/main/Compute/arms/newlinuxvm.params

wget https://raw.githubusercontent.com/wlamagna/Azure/refs/heads/main/Compute/arms/newlinuxvm.arm

