#!/usr/bin/env python3

import os
import requests
from vault_api import get_vault_api
from datetime import datetime

def setup_openai():
    print("\n🔑 OpenAI Integration Setup")
    print("========================")
    
    print("\n1. Visit: https://platform.openai.com/api-keys")
    print("2. Create a new API key")
    print("3. Set name: 'MachinaForge-Agent'")
    print("\nPaste your API Key here: ", end='')
    
    api_key = input().strip()
    
    if not api_key:
        print("❌ No API Key provided")
        return False
    
    # Verify the API key
    headers = {
        'Authorization': f'Bearer {api_key}',
        'Content-Type': 'application/json'
    }
    
    try:
        # Try to list models as a verification
        response = requests.get(
            'https://api.openai.com/v1/models',
            headers=headers
        )
        
        if response.status_code != 200:
            print(f"❌ API Key verification failed: {response.status_code}")
            return False
            
        # Get available models
        models = [m['id'] for m in response.json()['data']]
        gpt4_models = [m for m in models if 'gpt-4' in m]
        
        # Store in Vault
        vault = get_vault_api()
        vault.client.secrets.kv.v2.create_or_update_secret(
            path='openai',
            secret={
                'api_key': api_key,
                'available_models': models,
                'gpt4_models': gpt4_models,
                'created_at': datetime.utcnow().isoformat()
            },
            mount_point='kv'
        )
        
        # Update manifest
        vault.update_manifest('openai', {
            'api_key': 'present',
            'models': len(models),
            'gpt4_access': bool(gpt4_models)
        })
        
        print("\n✅ OpenAI API key verified and stored in Vault")
        print(f"✅ Access to {len(models)} models")
        if gpt4_models:
            print(f"✅ GPT-4 access confirmed: {', '.join(gpt4_models)}")
        print("✅ Manifest updated")
        return True
        
    except Exception as e:
        print(f"\n❌ Error: {str(e)}")
        return False

if __name__ == '__main__':
    setup_openai()

