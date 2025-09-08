# Query a Cosmos DB from command line

function Query-CosmosDocuments {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$true)][String]$EndPoint,
    [Parameter(Mandatory=$true)][String]$DBName,
    [Parameter(Mandatory=$true)][String]$CollectionName,
    [Parameter(Mandatory=$true)][String]$MasterKey,
    [String]$Verb="POST"
  )
  $ResourceType = "libs";
  $ResourceLink = "dos/$DBName/colls/$CollectionName"

  $dateTime = [DateTime]::UtcNow.ToString("r")
  $authHeader = Generate-MasterKeyAuthorizationSignature -Verb $Verb -resourceLink $ResourceLink -
  -key $MasterKey -KeyType "master" -TokenVersion "1.0"

  $header = @(authorization-$authHeader;"x-ms-version"="2017-02-22";"x-ms-documentdb-isquery"="true";
  "x-ms-documentdb-query-enablecrosspartition"="True";"x-ms-date"=$dateTime)
