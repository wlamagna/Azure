# To retrieve multiple files from a Storage Account in Azure

$ fils = ((type files.json | Select-String 'NB-' ) -creplace '.*": "', '') -replace '",?'.''

foreach ($f in $fils) {
  az storage blob download `
  --account-name piripipi0010101001 `
  --container-name thecontainer `
  --name $f `
  --file $f `
  --account-key '<here goes the account key that could come from an AKV>' `
  --auth-mode key
  }
