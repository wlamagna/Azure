# When deleting a VM in Azure it can leave some resources that were created for it,
# for exampale it can leave NSG, Interfaces.  One solution is to put the VM in its resource group
# and just delete the resource group.  But an other solution is to rung this script that
# gets the resources from the VM and deletes them specifically.
#
# Define your variables
RG_NAME="test01"
VM_NAME="vm01"

# 1. Get the resource IDs for the VM's OS disk, data disks, and NICs
OS_DISK=$(az vm show -g $RG_NAME -n $VM_NAME --query "storageProfile.osDisk.managedDisk.id" -o tsv)
DATA_DISKS=$(az vm show -g $RG_NAME -n $VM_NAME --query "storageProfile.dataDisks[].managedDisk.id" -o tsv)
NICS=$(az vm show -g $RG_NAME -n $VM_NAME --query "networkProfile.networkInterfaces[].id" -o tsv)

# 2. Get Public IPs associated with those NICs
PUBLIC_IPS=""
for nic in $NICS; do
    ip=$(az network nic show --ids $nic --query "ipConfigurations[].publicIPAddress.id" -o tsv)
    if [ ! -z "$ip" ]; then PUBLIC_IPS="$PUBLIC_IPS $ip"; fi
done

VNETS=""
for nic in $NICS; do
    vnetid=$(az network nic show --ids $nic --query "ipConfigurations[0].subnet.id" -o tsv )
    if [ ! -z "$vnetid" ]; then VNETS="$VNETS $vnetid"; fi
done

NSGS=""
for nic in $NICS; do
    nsgid=$(az network nic show --ids $nic --query "networkSecurityGroup.id" -o tsv )
    if [ ! -z "$nsgid" ]; then NSGS="$NSGS $nsgid"; fi
done


# 3. Delete the Virtual Machine
echo "Deleting VM: $VM_NAME"
az vm delete -g $RG_NAME -n $VM_NAME --yes

# 4. Delete the Network Interfaces (NICs)
if [ ! -z "$NICS" ]; then
    echo "Deleting NICs... $NICS"
    az network nic delete --ids $NICS
fi

# 5. Delete the Public IPs
if [ ! -z "$PUBLIC_IPS" ]; then
    echo "Deleting Public IPs... $PUBLIC_IPS"
    az network public-ip delete --ids $PUBLIC_IPS
fi

# 6. Delete Managed Disks (OS and Data)
if [ ! -z "$OS_DISK" ]; then
    echo "Deleting OS Disk... $OS_DISK"
    az disk delete --ids $OS_DISK --yes
fi

# 7. Delete Data Disks
for disk in $DATA_DISKS; do
    echo "Deleting Data Disk: $disk"
    az disk delete --ids $disk --yes
done

# 8. Delete the Virtual Network (VNET)
if [ ! -z "$VNETS" ]; then
    echo "Deleting VNETs... $VNETS"
    az network vnet delete --ids $VNETS
fi

# 9. Delete the Network Security Groups (NSGs)
if [ ! -z "$NSGS" ]; then
    echo "Deleting NSGs... $NSGS"
    az network nsg delete --ids $NSGS
fi