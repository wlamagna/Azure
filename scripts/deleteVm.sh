# When deleting a VM in Azure it can leave some resources that were created for it,
# for exampale it can leave NSG, Interfaces.  One solution is to put the VM in its resource group
# and just delete the resource group.  But an other solution is to rung this script that
# gets the resources from the VM and deletes them specifically.
#
# Define your variables
RG_NAME="MyResourceGroup"
VM_NAME="MyVM"

# 1. Get the resource IDs for the VM's OS disk, data disks, and NICs
OS_DISK=$(az vm show -g $RG_NAME -n $VM_NAME --query "storageProfile.osDisk.managedDisk.id" -o tsv)
DATA_DISKS=$(az vm show -g $RG_NAME -n $VM_NAME --query "storageProfile.dataDisks[].managedDisk.id" -o tsv)
NICS=$(az vm show -g $RG_NAME -n $VM_NAME --query "networkProfile.networkInterfaces[].id" -o tsv)

# 2. Get Public IPs associated with those NICs
PUBLIC_IPS=""
for nic in $NICS; do
    ip=$(az network nic show --ids $nic --query "ipConfigurations[].publicIpAddress.id" -o tsv)
    if [ ! -z "$ip" ]; then PUBLIC_IPS="$PUBLIC_IPS $ip"; fi
done

# 3. Delete the Virtual Machine
echo "Deleting VM: $VM_NAME"
az vm delete -g $RG_NAME -n $VM_NAME --yes

# 4. Delete the Network Interfaces (NICs)
if [ ! -z "$NICS" ]; then
    echo "Deleting NICs..."
    az network nic delete --ids $NICS
fi

# 5. Delete the Public IPs
if [ ! -z "$PUBLIC_IPS" ]; then
    echo "Deleting Public IPs..."
    az network public-ip delete --ids $PUBLIC_IPS
fi

# 6. Delete Managed Disks (OS and Data)
if [ ! -z "$OS_DISK" ]; then
    echo "Deleting OS Disk..."
    az disk delete --ids $OS_DISK --yes
fi

for disk in $DATA_DISKS; do
    echo "Deleting Data Disk: $disk"
    az disk delete --ids $disk --yes
done

