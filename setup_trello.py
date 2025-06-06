#!/usr/bin/env python3

import os
import json
import requests
from vault_api import get_vault_api
from datetime import datetime

def setup_trello():
    print("\n🔑 Trello Integration Setup")
    print("========================")
    
    # Get existing API secret from Vault
    vault = get_vault_api()
    
    try:
        existing = vault.client.secrets.kv.v2.read_secret_version(
            path='trello',
            mount_point='kv'
        )['data']['data']
        api_secret = existing.get('api_secret')
    except Exception:
        api_secret = os.getenv('TRELLO_API_SECRET')
    
    if not api_secret:
        print("❌ No Trello API secret found in Vault or environment")
        return False
    
    print("\n1. Visit: https://trello.com/app-key")
    print("2. Login if needed")
    print("3. Accept Developer Terms")
    print("4. Copy API Key")
    print("\nPaste your API Key here: ", end='')
    
    api_key = input().strip()
    
    if not api_key:
        print("❌ No API Key provided")
        return False
    
    # Generate token URL
    token_url = f"https://trello.com/1/authorize?expiration=never&name=MachinaForge&scope=read,write&response_type=token&key={api_key}"
    
    print(f"\n🔗 Visit this URL to generate your token:")
    print(token_url)
    print("\nPaste your token here: ", end='')
    
    token = input().strip()
    
    if not token:
        print("❌ No token provided")
        return False
    
    # Verify credentials
    test_url = f"https://api.trello.com/1/members/me?key={api_key}&token={token}"
    response = requests.get(test_url)
    
    if response.status_code != 200:
        print(f"❌ Token verification failed: {response.status_code}")
        return False
    
    # Store in Vault
    vault.client.secrets.kv.v2.create_or_update_secret(
        path='trello',
        secret={
            'api_key': api_key,
            'token': token,
            'api_secret': api_secret,
            'created_at': datetime.utcnow().isoformat()
        },
        mount_point='kv'
    )
    
    # Update manifest
    vault.update_manifest('trello', {
        'api_key': 'present',
        'token': 'present',
        'api_secret': 'present'
    })
    
    print("\n✅ Trello credentials verified and stored in Vault")
    print("✅ Manifest updated")
    return True

if __name__ == '__main__':
    setup_trello()

