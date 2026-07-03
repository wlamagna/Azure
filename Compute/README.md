#### Create a VM to Create the Docker files

az deployment group create --resource-group $RG --name newdeploy2025 \
--template-file arms/newlinuxvm.arm \
--parameters @arms/newlinuxvm.params


