# Query a Cosmos DB from command line

function Query-CosmosDocuments {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$true)][String]$EndPoint,
    [Parameter(Mandatory=$true)][String]$DBName,
    [Parameter(Mandatory=$true)][String]$CollectionName,
    [Parameter(Mandatory=$true)][String]$MasterKey,
    
