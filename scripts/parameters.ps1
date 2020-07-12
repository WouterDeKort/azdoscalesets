$currentAzContext = Get-AzContext

$subscriptionID = $currentAzContext.Subscription.Id
$imageResourceGroup = "aibwinsig"
$location = "westeurope"
$runOutputName = "aibCustWinManImg02ro"
$imageTemplateName = "helloImageTemplateWin02ps"
$runOutputName = "winclientR01"

# setup role def names, these need to be unique
$timeInt = $(get-date -UFormat "%s")
$imageRoleDefName = "Azure Image Builder Image Def" + $timeInt
$identityName = "aibIdentity" + $timeInt

# Image gallery name
$sigGalleryName = "myIBSIG"

# Image definition name
$imageDefName = "winSvrimage"

# additional replication region
$replRegion2 = "northeurope"

$agentPoolResourceGroup = "myAgents"