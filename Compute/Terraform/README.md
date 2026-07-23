###  Terraform scripts for modularized deployment and IaC management
```
az provider register --namespace Microsoft.Kusto
terraform version
```

#### The plan command evaluates your configuration against your current infrastructure (if any) and outputs exactly what actions Terraform will take (create, update, or delete resources). It does not deploy anything yet.
```
terraform plan
```
#### Once you have reviewed the execution plan and are satisfied, you can deploy the resources.
```
terraform apply
```
#### The structure could be
```
Terraform  
|
|--- rg (tf files for resources that are permanent)
|--- vms (these could be the temporal vms required to create the docker files)
```

