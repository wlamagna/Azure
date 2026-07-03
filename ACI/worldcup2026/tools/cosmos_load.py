#!.venv/bin/python
import sys
import os
from azure.keyvault.secrets import SecretClient
from azure.identity import AzureCliCredential
#from azure.identity import DefaultAzureCredential
from azure.cosmos import CosmosClient, PartitionKey, exceptions

VAULT_URL = "https://kvcup2026.vault.azure.net/"
COSMOS_URL = "https://test01account.documents.azure.com:443"


def retrieve_secret(secret_name: str) -> str:
    try:
        credential = AzureCliCredential()
        # This automatically tries Environment, Managed Identity, CLI, etc.
        #credential = DefaultAzureCredential()
        # 3. Initialize the Secret Client
        client = SecretClient(vault_url=VAULT_URL, credential=credential)
        print(f"Fetching secret '{secret_name}' from Key Vault...")
        # 4. Retrieve the secret object
        retrieved_secret = client.get_secret(secret_name)
        # 5. Extract and return the plaintext secret value
        return retrieved_secret.value
    except Exception as e:
        print(f"An error occurred: {e}")
        return None

SECRET_TO_FETCH = "cosmosdb"
CONTAINER_NAME = 'players'
DATABASE_NAME = 'cup2026'
print ("retrieving secret....")
secret_value = retrieve_secret(SECRET_TO_FETCH)
if (secret_value is None):
    sys.exit(1);

print (f"key: {secret_value}")


# 1. Initialize and get container
client = CosmosClient(COSMOS_URL, credential=secret_value)
database = client.get_database_client(DATABASE_NAME)
container = database.get_container_client(CONTAINER_NAME)
try:
    container = client.create_database_if_not_exists("cup2026").create_container_if_not_exists(
        id="players", partition_key=PartitionKey(path="/partitionKey")
    )
except Exception as e:
    print(f"An error occurred: {e}")

#
# 2. Define and create record
i=1
with open('players.csv', "r") as file:
    for line in file:
        line = line.strip()
        playerData = line.split("\t")
        print(f"{playerData[0]}")
        print(f"{playerData[1]}")
        new_record = {"id": f"{i}", "partitionKey": "A", "player": f"{playerData[1]}", "country": f"{playerData[0]}"}
        i=i+1
        try:
            container.create_item(body=new_record)
        except Exception as e:
            print(f"An error occurred: {e}")

