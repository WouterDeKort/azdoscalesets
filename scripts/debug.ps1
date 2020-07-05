az group create `
    --location westeurope `
    --name vmssagents

az vmss create `
    --name vmssagentspool `
    --resource-group vmssagents `
    --image UbuntuLTS `
    --vm-sku Standard_D2_v3 `
    --storage-sku StandardSSD_LRS `
    --authentication-type SSH `
    --instance-count 2 `
    --disable-overprovision `
    --upgrade-policy-mode manual `
    --single-placement-group false `
    --load-balancer '""' `
    --platform-fault-domain-count 1 `
    --admin-username myusername `
    --generate-ssh-keys
    #--admin-password myPassword
    
#https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/tutorial-use-custom-image-cli

#https://github.com/actions/virtual-environments/blob/master/images/win/Windows2019-Azure.json
az vmss update `
    --resource-group myResourceGroup `
    --name myScaleSet `
    --set virtualMachineProfile.storageProfile.imageReference.id=/subscriptions/{subscriptionID}/resourceGroups/myResourceGroup/providers/Microsoft.Compute/images/myNewImage