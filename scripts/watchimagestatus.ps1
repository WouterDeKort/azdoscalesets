. .\parameters.ps1

$azureRmProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
$profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azureRmProfile)
    
Write-Verbose ("Tenant: {0}" -f $currentAzContext.Subscription.Name)
 
### Step 4: Get token  
$token = $profileClient.AcquireAccessToken($currentAzContext.Tenant.TenantId)
$accessToken = $token.AccessToken

$managementEp = $currentAzContext.Environment.ResourceManagerUrl

$urlBuildStatus = [System.String]::Format("{0}subscriptions/{1}/resourceGroups/$imageResourceGroup/providers/Microsoft.VirtualMachineImages/imageTemplates/{2}?api-version=2019-05-01-preview", $managementEp, $currentAzContext.Subscription.Id, $imageTemplateName)

$buildStatusResult = Invoke-WebRequest -Method GET -Uri $urlBuildStatus -UseBasicParsing -Headers  @{"Authorization" = ("Bearer " + $accessToken) } -ContentType application/json 
$buildJsonStatus = $buildStatusResult.Content | ConvertFrom-Json
$buildJsonStatus.properties.lastRunStatus