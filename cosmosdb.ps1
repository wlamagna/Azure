# Query a cosmos DB from A script
# This is one i am proud of, i needed to query a Cosmos DB in Azure and to automate the task
# i created this script to make my life easy.

$cosmosDBAccountName = "pepe05"
$cosmosDBDatabaseName = "pepedb"
$cosmosDBContainerNAme ="Integration"

$rgName ="wei-wt-u-look-rsg"

$User = "MYSP01@opentowork.com"
# Yes, i love this one, not even i need to know the password:"
$Password=$(Get-Clipboard)
$PWord = ConvertTo-SecureString -String "$Password" -AsPlainText -Force
$contexts=(Get-AzContext)
if (($contexts.Name).Length -eq 0) {
  $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord
  Connect-AzAccount -Credential $Credential -Scope Process
  Set-AzContext -SubscriptionName "PA-TARA-PROD-GUI KERN-01-99999999"
}
$cosmosDBAccountKey = (Get-AzCosmosDBAccountKey -ResourceGroupName $rgName -Name $cosmosDBAccountName).PrimaryMasterKey
$cosmosDBAccountKey | clip

$primaryKey = ConvertTo-SecureString -String $cosmosDBAccountKey -AsPlainText -Force
Get-CosmosDbDocument -Context $cosmosDbContext -CollectionId "myContainer" -Id "7e7e7e7e-b1ab-b1la-8e8e8e8e8e8e",
$cosmosDbContext = NewCosmosDbContext -Account $accountName -Dtabase $databaseName -ResourceGroup $resourceGroupName
$query = "SELECT * from names c where c.id = '0'"
(Get-CosmosDbDocument -Context $cosmosDbContext -CollectionId $cosmosDBContainerName -Query $query) | Select-Object ($_.deviceid)
Disconnect-AzAccount



