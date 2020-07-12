 . .\parameters.ps1

# Create a resource group for Image Template and Shared Image Gallery
New-AzResourceGroup `
    -Name $imageResourceGroup `
    -Location $location `
    -Force

# create identity
New-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName

$identityNameResourceId = $(Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName).Id
$identityNamePrincipalId = $(Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName).PrincipalId

$aibRoleImageCreationUrl = "https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/solutions/12_Creating_AIB_Security_Roles/aibRoleImageCreation.json"
$aibRoleImageCreationPath = "aibRoleImageCreation.json"

# download config
Invoke-WebRequest -Uri $aibRoleImageCreationUrl -OutFile $aibRoleImageCreationPath -UseBasicParsing

((Get-Content -path $aibRoleImageCreationPath -Raw) -replace '<subscriptionID>', $subscriptionID) | Set-Content -Path $aibRoleImageCreationPath
((Get-Content -path $aibRoleImageCreationPath -Raw) -replace '<rgName>', $imageResourceGroup) | Set-Content -Path $aibRoleImageCreationPath
((Get-Content -path $aibRoleImageCreationPath -Raw) -replace 'Azure Image Builder Service Image Creation Role', $imageRoleDefName) | Set-Content -Path $aibRoleImageCreationPath

# create role definition
New-AzRoleDefinition -InputFile  ./aibRoleImageCreation.json

# grant role definition to image builder service principal
New-AzRoleAssignment -ObjectId $identityNamePrincipalId -RoleDefinitionName $imageRoleDefName -Scope "/subscriptions/$subscriptionID/resourceGroups/$imageResourceGroup"

# Create the gallery
New-AzGallery `
    -GalleryName $sigGalleryName `
    -ResourceGroupName $imageResourceGroup  `
    -Location $location

# Create the image definition
New-AzGalleryImageDefinition `
    -GalleryName $sigGalleryName `
    -ResourceGroupName $imageResourceGroup `
    -Location $location `
    -Name $imageDefName `
    -OsState generalized `
    -OsType Windows `
    -Publisher 'Wouter_de_Kort' `
    -Offer 'WindowsServer' `
    -Sku 'WinSrv2019'

$templateFilePath = "armTemplateWinSIG.json"

Invoke-WebRequest `
    -Uri "https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/quickquickstarts/1_Creating_a_Custom_Win_Shared_Image_Gallery_Image/armTemplateWinSIG.json" `
    -OutFile $templateFilePath `
    -UseBasicParsing
   
(Get-Content -path $templateFilePath -Raw ) `
    -replace '<subscriptionID>', $subscriptionID | Set-Content -Path $templateFilePath
(Get-Content -path $templateFilePath -Raw ) `
    -replace '<rgName>', $imageResourceGroup | Set-Content -Path $templateFilePath
(Get-Content -path $templateFilePath -Raw ) `
    -replace '<runOutputName>', $runOutputName | Set-Content -Path $templateFilePath
(Get-Content -path $templateFilePath -Raw ) `
    -replace '<imageDefName>', $imageDefName | Set-Content -Path $templateFilePath
(Get-Content -path $templateFilePath -Raw ) `
    -replace '<sharedImageGalName>', $sigGalleryName | Set-Content -Path $templateFilePath
(Get-Content -path $templateFilePath -Raw ) `
    -replace '<region1>', $location | Set-Content -Path $templateFilePath
(Get-Content -path $templateFilePath -Raw ) `
    -replace '<region2>', $replRegion2 | Set-Content -Path $templateFilePath
((Get-Content -path $templateFilePath -Raw) -replace '<imgBuilderId>', $identityNameResourceId) | Set-Content -Path $templateFilePath

New-AzResourceGroupDeployment `
    -ResourceGroupName $imageResourceGroup `
    -TemplateFile $templateFilePath `
    -api-version "2019-05-01-preview" `
    -imageTemplateName $imageTemplateName `
    -svclocation $location

Invoke-AzResourceAction `
    -ResourceName $imageTemplateName `
    -ResourceGroupName $imageResourceGroup `
    -ResourceType Microsoft.VirtualMachineImages/imageTemplates `
    -ApiVersion "2019-05-01-preview" `
    -Action Run

