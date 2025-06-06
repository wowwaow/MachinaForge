#!/usr/bin/env python3

import subprocess
import json
from vault_api import get_vault_api
from datetime import datetime

def setup_github():
    print("\n🔑 GitHub Token Setup")
    print("===================")
    print("\n1. Visit: https://github.com/settings/tokens/new")
    print("2. Set token name: 'MachinaForge-Agent'")
    print("3. Set expiration: Custom -> 365 days")
    print("4. Select scopes:")
    print("   - repo (all)")
    print("   - workflow")
    print("   - read:org")
    print("   - read:packages")
    print("   - write:packages")
    print("\nPaste your token here: ", end='')
    
    token = input().strip()
    
    if not token:
        print("❌ No token provided. Aborting.")
        return False
        
    try:
        # Test the token
        process = subprocess.run(
            ['gh', 'auth', 'login', '--with-token'],
            input=token.encode(),
            capture_output=True
        )
        
        if process.returncode != 0:
            print(f"❌ Token validation failed: {process.stderr.decode()}")
            return False
            
        # Store in Vault
        vault = get_vault_api()
        
        # Add to Vault
        vault.client.secrets.kv.v2.create_or_update_secret(
            path='github',
            secret={
                'token': token,
                'scopes': [
                    'repo', 'workflow', 'read:org',
                    'read:packages', 'write:packages'
                ],
                'created_at': datetime.utcnow().isoformat()
            },
            mount_point='kv'
        )
        
        # Update manifest
        vault.update_manifest('github', {
            'token': 'present',
            'scopes': [
                'repo', 'workflow', 'read:org',
                'read:packages', 'write:packages'
            ]
        })
        
        print("\n✅ GitHub token stored in Vault")
        print("✅ Manifest updated")
        return True
        
    except Exception as e:
        print(f"\n❌ Error: {str(e)}")
        return False

if __name__ == '__main__':
    setup_github()

