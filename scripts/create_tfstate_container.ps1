# Variables
$resourceGroupName = "tfstate"
$storageAccountName = "satfstate120325"
$containerName = "tfstate"
$location = "West Europe"

# Create Resource Group
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Create Storage Account
New-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName -Location $location -SkuName Standard_LRS

# Get Storage Account Context
$storageAccountContext = New-AzStorageContext -StorageAccountName $storageAccountName -UseConnectedAccount

# Create Blob Container
New-AzStorageContainer -Name $containerName -Context $storageAccountContext -Permission Off