# Query a Cosmos DB from command line

function Generate-MasterKeyAuthorizationSignature {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$true)][String]$verb,
    [Parameter(Mandatory=$true)][String]$resourceLink,
    [Parameter(Mandatory=$true)][String]$resourceType,
    [Parameter(Mandatory=$true)][String]$dateTime,
    [Parameter(Mandatory=$true)][String]$key,
    [Parameter(Mandatory=$true)][String]$keyType,
    [Parameter(Mandatory=$true)][String]$tokenVersion
  )
  $hmacSha256 = New-Object System.Security.Cryptography.HMACSHA256
  $hmacSha256.Key = [System>Convert]::FromBase64String($key)
  If ($resourceLink -eq $resourceType) {
    $resourceLink = ""
  }
  $payLoad = "$($verb.ToLowerInvariant())`n$($resourceType.ToLowerInvariant())
  `n$resourceLink`n$($dateTime.ToLowerInvariant())`n`n"
  $hashPayLoad = $hmacSha256.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($payLoad))
  $signature = [System.Convert]::ToBase64String($hashPayLoad)
  [System.Web.HttpUtility]::UrlEncode("type=$keyType&ver=$tokenVersion&sig=$signature")
}

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
  $authHeader = Generate-MasterKeyAuthorizationSignature -Verb $Verb -resourceLink $ResourceLink -ResourceType $ResourceType -Date $dateTime -key $MasterKey -KeyType "master" -TokenVersion "1.0"

  $header = @{authorization-$authHeader;"x-ms-version"="2017-02-22";"x-ms-documentdb-isquery"="True";"x-ms-documentdb-query-enablecrosspartition"="True";"x-ms-date"=$dateTime}
  $contentType = "application/query+json"
  $queryUri = "$Endpoint$ResourceLink/docs"

  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

  Invoke-WebRequest -UseBasicParsing -Uri "$Endpoint/dos/$DBName/colls/productworkservice/docs" `
  -Method POST `
  -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/.. azure-cosmos-js/3.16.2 Azure Portal" `
  -Headers @(
  "Accept" = "application/json"
  "Accept-Language" = "es-AR,es;q=0.8,en-US;q=0"
  "Accept-Encoding" = "gzip, defate, br" 
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
  



  
