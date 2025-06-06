#!/usr/bin/env python3

import os
import requests
from vault_api import get_vault_api
from datetime import datetime

def setup_anthropic():
    print("\n🔑 Anthropic/Claude Integration Setup")
    print("================================")
    
    api_key = "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"
    
    # Verify the API key
    headers = {
        'x-api-key': api_key,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json'
    }
    
    try:
        # Try to list models as a verification
        response = requests.get(
            'https://api.anthropic.com/v1/models',
            headers=headers
        )
        
        if response.status_code != 200:
            print(f"❌ API Key verification failed: {response.status_code}")
            return False
            
        # Get available models
        models = response.json().get('models', [])
        claude_models = [m['name'] for m in models if 'claude' in m['name'].lower()]
        
        # Store in Vault
        vault = get_vault_api()
        vault.client.secrets.kv.v2.create_or_update_secret(
            path='anthropic',
            secret={
                'api_key': api_key,
                'available_models': [m['name'] for m in models],
                'claude_models': claude_models,
                'created_at': datetime.utcnow().isoformat()
            },
            mount_point='kv'
        )
        
        # Update manifest
        vault.update_manifest('anthropic', {
            'api_key': 'present',
            'models': len(models),
            'claude_access': bool(claude_models)
        })
        
        print("\n✅ Anthropic API key verified and stored in Vault")
        print(f"✅ Access to {len(models)} models")
        if claude_models:
            print(f"✅ Claude access confirmed: {', '.join(claude_models)}")
        print("✅ Manifest updated")
        return True
        
    except Exception as e:
        print(f"\n❌ Error: {str(e)}")
        return False

if __name__ == '__main__':
    setup_anthropic()

