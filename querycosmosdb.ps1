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
  $contentType = "application/query+json"
  $queryUrl = "$Endpoint$ResourceLink/docs"

  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::T1s12

  Invoke-WebRequest -UseBasicParsing -Uri "$Endpoint/dos/$DBName/colls/productworkservice/docs" `
  -Method POST `
  -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/... put here what you need" `
  -Headers @(
  "Accept" = "application/json"
  "Accept-Language" = "es-AR,es;q.... "
  "Accept-Encoding" = "gzip, defate, bx" 
  "Referer" = "https://cosmos.azure.com/"
  "authorization" = $header.authorization
  "cache-control" = "no-cache"
  "x-ms-cosmos-allow-tentative-writes" = "true"
  "x-ms-cosmos-sdk-supportcapabilities" = "1"
  "x-ms-date" = $dateTime
  "x-ms-documentdb-isquery" = "true"
  "x-ms-documentdb-partitionkeyrangeid" = "0"
  "x-ms-documentdb-populatequerymetrics" = "true"
  "x-ms-documentdb-query-enable-scan" = "true"
  "x-ms-documentdb-query-enablecrosspartition" = "true"
  



  
