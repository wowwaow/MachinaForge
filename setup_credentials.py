#!/usr/bin/env python3

from vault_api import get_vault_api
import os
from datetime import datetime

def setup_credentials():
    # Initialize Vault API
    vault = get_vault_api()
    
    # Define credentials to store
    credentials = {
        'anthropic': {
            'api_key': os.getenv('ANTHROPIC_API_KEY', '')
        },
        'openai': {
            'api_key': os.getenv('OPENAI_API_KEY', '')
        },
        'deepseek': {
            'api_key': os.getenv('DEEPSEEK_API_KEY', '')
        },
        'google_cloud': {
            'project_id': os.getenv('GOOGLE_CLOUD_PROJECT', ''),
            'oauth_client_secret': os.getenv('GOOGLE_OAUTH_CLIENT_SECRET', '')
        },
        'hetzner': {
            'api_token': os.getenv('HETZNER_API_TOKEN', ''),
            'bucket_access_key': os.getenv('HETZNER_BUCKET_ACCESS_KEY', ''),
            'bucket_secret_key': os.getenv('HETZNER_BUCKET_SECRET_KEY', '')
        },
        'r1': {
            'api_key': os.getenv('R1_API_KEY', '')
        }
    }
    
    # Store each credential set and update manifest
    for service, creds in credentials.items():
        if any(creds.values()):
            # Store the credentials
            vault.client.secrets.kv.v2.create_or_update_secret(
                path=service,
                secret={
                    **creds,
                    'created_at': datetime.utcnow().isoformat()
                },
                mount_point='kv'
            )
            
            # Update manifest
            manifest_entry = {k: 'present' for k in creds.keys()}
            vault.update_manifest(service, manifest_entry)
            
            print(f"✅ Stored {service} credentials")
        else:
            print(f"⚠️ Skipping {service} - no credentials found")

if __name__ == '__main__':
    setup_credentials()

