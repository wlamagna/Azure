Azure App Service (Linux, multi-container) with images stored in Azure Container Registry (ACR), we’ll create two pipelines in Azure DevOps:

azure-pipelines-build.yml → CI:

Trigger on pushes to your staging branch.

Build Node.js API & React frontend from your GitHub repo.

Push images to ACR tagged staging.

azure-pipelines-deploy.yml → CD:

Triggered after build completes.

Uses Terraform (or Azure CLI) to apply infra.

Restarts App Service staging slot so it pulls the new images.
