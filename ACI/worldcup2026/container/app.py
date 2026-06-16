from flask import Flask, request
from azure.cosmos import CosmosClient
import os
import json
import random
import sys

from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential

VAULT_URL = "https://kvwcup2026.vault.azure.net/"
COSMOS_URL = "https://test01account.documents.azure.com:443"
SECRET_TO_FETCH = "cosmosdb"
CONTAINER_NAME = 'players'
DATABASE_NAME = 'cup2026'


def retrieve_secret(secret_name: str) -> str:
    try:
        credential = DefaultAzureCredential()
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

app = Flask(__name__)



@app.route('/')
def home():
    description = fr'''
    <html>
    <body>
    <pre>
     \ 
     - \ 
     |   \ 
     |---- \ 
     |  KKB  \ 
     |---------\ 
      \          \ 
        \--------O-\ 
          \----^-|-^-\ 
            \___/_\____\ 
            __/_____\____\___/
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    "The most beautiful shapes on earth were created by the wind."
    </pre>
    </body>
    </html>
    '''
    return description

@app.route('/api')
def api():
    client = CosmosClient(COSMOS_URL, credential=secret_value)
    database = client.get_database_client(DATABASE_NAME)
    container = database.get_container_client(CONTAINER_NAME)
    # Enumerate the returned items
    random_player=random.randrange(1, 96, 1)
    print(f"reading: {random_player}")
    output = ""
    for item in container.query_items(
    query=f"SELECT * FROM players r WHERE r.id='{random_player}'",
    enable_cross_partition_query=True):
        output = output + json.dumps(item, indent=True)
        #  print(json.dumps(item, indent=True))
    return output


if __name__ == '__main__':
  print ("retrieving secret....")
  secret_value = retrieve_secret(SECRET_TO_FETCH)
  app.run(host='0.0.0.0', port=5000)
