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

