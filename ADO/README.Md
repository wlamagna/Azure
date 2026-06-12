### Deploying some projects but from the Azure Devops Pipeline tool
#### For all this to work, in Azure, create the Managed Identity.

Create a new Azure Service Connection
```
Identity Type: Managed identity
Select the subscription, the Managemeng Group where the managed identity is located, and it managed identity itself.

Step 2: Azure Scope
(*) Subscriptoin

Step 3: A name: MyAzureServiceConnection
```



