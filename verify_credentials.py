#!/usr/bin/env python3

import requests
import json
from datetime import datetime
from vault_api import get_vault_api
from typing import Dict, Any, List, Tuple
import sys

class CredentialVerifier:
    def __init__(self):
        self.vault = get_vault_api()
        self.results: List[Dict[str, Any]] = []
        self.all_valid = True

    def add_result(self, service: str, status: bool, message: str, details: Dict[str, Any] = None):
        result = {
            'service': service,
            'status': status,
            'message': message,
            'timestamp': datetime.utcnow().isoformat(),
            'details': details or {}
        }
        self.results.append(result)
        if not status:
            self.all_valid = False

    def verify_trello(self):
        try:
            creds = self.vault.get_credential('trello')
            api_key = creds['api_key']
            
            # Test API access
            # We need both API key and token for Trello
            token = creds.get('token')
            if not token:
                self.add_result('Trello', False, 'Missing token')
                return
                
            response = requests.get(
                f'https://api.trello.com/1/members/me?key={api_key}&token={token}'
            )
            
            if response.status_code == 200:
                self.add_result('Trello', True, 'API access verified', {
                    'username': response.json().get('username')
                })
            else:
                self.add_result('Trello', False, f'API access failed: {response.status_code}')
        except Exception as e:
            self.add_result('Trello', False, f'Verification failed: {str(e)}')

    def verify_openai(self):
        try:
            creds = self.vault.get_credential('openai')
            api_key = creds['api_key']
            
            headers = {
                'Authorization': f'Bearer {api_key}',
                'Content-Type': 'application/json'
            }
            
            response = requests.get(
                'https://api.openai.com/v1/models',
                headers=headers
            )
            
            if response.status_code == 200:
                models = response.json()['data']
                gpt4_models = [m['id'] for m in models if 'gpt-4' in m['id']]
                self.add_result('OpenAI', True, 'API access verified', {
                    'total_models': len(models),
                    'gpt4_models': gpt4_models
                })
            else:
                self.add_result('OpenAI', False, f'API access failed: {response.status_code}')
        except Exception as e:
            self.add_result('OpenAI', False, f'Verification failed: {str(e)}')

    def verify_anthropic(self):
        try:
            creds = self.vault.get_credential('anthropic')
            api_key = creds['api_key']
            
            headers = {
                'x-api-key': api_key,
                'anthropic-version': '2023-06-01',
                'content-type': 'application/json'
            }
            
            # Test with a simple message
            response = requests.post(
                'https://api.anthropic.com/v1/messages',
                headers=headers,
                json={
                    'model': 'claude-3-opus-20240229',
                    'messages': [{'role': 'user', 'content': 'Test'}],
                    'max_tokens': 1
                }
            )
            
            if response.status_code == 200:
                self.add_result('Anthropic', True, 'API access verified', {
                    'model': 'claude-3-opus-20240229'
                })
            else:
                self.add_result('Anthropic', False, f'API access failed: {response.status_code}')
        except Exception as e:
            self.add_result('Anthropic', False, f'Verification failed: {str(e)}')

    def verify_github(self):
        try:
            creds = self.vault.get_credential('github')
            token = creds['token']
            repo = creds['repo']
            
            headers = {
                'Authorization': f'token {token}',
                'Accept': 'application/vnd.github.v3+json'
            }
            
            response = requests.get(
                'https://api.github.com/user',
                headers=headers
            )
            
            if response.status_code == 200:
                user_data = response.json()
                self.add_result('GitHub', True, 'API access verified', {
                    'username': user_data['login'],
                    'repo': repo
                })
            else:
                self.add_result('GitHub', False, f'API access failed: {response.status_code}')
        except Exception as e:
            self.add_result('GitHub', False, f'Verification failed: {str(e)}')

    def verify_deepseek(self):
        try:
            creds = self.vault.get_credential('deepseek')
            api_key = creds['api_key']
            
            headers = {
                'Authorization': f'Bearer {api_key}',
                'Content-Type': 'application/json'
            }
            
            # Test with a simple completion request
            response = requests.post(
                'https://api.deepseek.com/v1/chat/completions',
                headers=headers,
                json={
                    'model': 'deepseek-chat',
                    'messages': [{'role': 'user', 'content': 'Test'}],
                    'max_tokens': 1
                }
            )
            
            if response.status_code == 200:
                self.add_result('DeepSeek', True, 'API access verified')
            else:
                self.add_result('DeepSeek', False, f'API access failed: {response.status_code}')
        except Exception as e:
            self.add_result('DeepSeek', False, f'Verification failed: {str(e)}')

    def verify_hetzner(self):
        try:
            creds = self.vault.get_credential('hetzner')
            token = creds['api_token']
            
            headers = {'Authorization': f'Bearer {token}'}
            
            response = requests.get(
                'https://api.hetzner.cloud/v1/servers',
                headers=headers
            )
            
            if response.status_code == 200:
                self.add_result('Hetzner', True, 'API access verified')
            else:
                self.add_result('Hetzner', False, f'API access failed: {response.status_code}')
        except Exception as e:
            self.add_result('Hetzner', False, f'Verification failed: {str(e)}')

    def verify_r1(self):
        try:
            creds = self.vault.get_credential('r1')
            api_key = creds['api_key']
            
            # Add R1-specific verification here
            # For now, just verify we can get the key
            if api_key:
                self.add_result('R1', True, 'API key retrieved')
            else:
                self.add_result('R1', False, 'API key not found')
        except Exception as e:
            self.add_result('R1', False, f'Verification failed: {str(e)}')

    def print_results(self):
        print("\n🔑 Credential Verification Results")
        print("================================")
        
        for result in self.results:
            status_icon = "✅" if result['status'] else "❌"
            print(f"\n{status_icon} {result['service']}")
            print(f"   Status: {'Valid' if result['status'] else 'Invalid'}")
            print(f"   Message: {result['message']}")
            if result['details']:
                print("   Details:")
                for k, v in result['details'].items():
                    print(f"     - {k}: {v}")

        print("\n=== Summary ===")
        print(f"Total Services: {len(self.results)}")
        valid_count = sum(1 for r in self.results if r['status'])
        print(f"Valid: {valid_count}")
        print(f"Invalid: {len(self.results) - valid_count}")
        print(f"Overall Status: {'✅ All Valid' if self.all_valid else '❌ Some Invalid'}")

    def verify_all(self):
        print("\n🔍 Starting Credential Verification...\n")
        
        # Verify each service
        self.verify_trello()
        self.verify_openai()
        self.verify_anthropic()
        self.verify_github()
        self.verify_deepseek()
        self.verify_hetzner()
        self.verify_r1()
        
        # Print results
        self.print_results()
        
        # Return overall status
        return self.all_valid

def main():
    verifier = CredentialVerifier()
    success = verifier.verify_all()
    sys.exit(0 if success else 1)

if __name__ == '__main__':
    main()

