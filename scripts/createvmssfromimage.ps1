. .\parameters.ps1

$imageDefinition = Get-AzGalleryImageDefinition `
   -GalleryName $sigGalleryName `
   -ResourceGroupName $imageResourceGroup `
   -Name $imageDefName

$imageDefinition

az vmss create `
    --name vmssagentspool `
    --resource-group $imageResourceGroup  `
    --vm-sku Standard_D2_v3 `
    --storage-sku StandardSSD_LRS `
    --instance-count 0 `
    --disable-overprovision `
    --upgrade-policy-mode manual `
    --single-placement-group false `
    --platform-fault-domain-count 1 `
    --load-balancer '""' `
    --image $imageDefinition.Id `
    --admin-username "Wouter" `
    --admin-password "mysupersecretpassword12()"
