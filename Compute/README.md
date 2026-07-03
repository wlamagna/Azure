#### Create a VM to Create the Docker files

az deployment group create --resource-group $RG --name newdeploy2025 \
--template-file arms/newlinuxvm.arm \
--parameters @arms/newlinuxvm.params


wget https://raw.githubusercontent.com/wlamagna/Azure/refs/heads/main/Compute/arms/newlinuxvm.params

wget https://raw.githubusercontent.com/wlamagna/Azure/refs/heads/main/Compute/arms/newlinuxvm.arm

