Azure App Service (Linux, multi-container) with images stored in Azure Container Registry (ACR), we’ll create two pipelines in Azure DevOps:

azure-pipelines-build.yml → CI:

Trigger on pushes to your staging branch.

Build Node.js API & React frontend from your GitHub repo.

Push images to ACR tagged staging.

azure-pipelines-deploy.yml → CD:

Triggered after build completes.

Uses Terraform (or Azure CLI) to apply infra.

Restarts App Service staging slot so it pulls the new images.


👉 Setup required in Azure DevOps:

Create an Azure Resource Manager service connection called AzureRM (Project Settings → Service connections → Azure Resource Manager).

Store sensitive values (BASIC_AUTH_USER, BASIC_AUTH_HASH) in Pipeline → Variables (mark as secret).

Configure Terraform backend storage (Storage Account + Container) for state.
