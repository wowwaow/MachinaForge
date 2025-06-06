import hvac
import json
from typing import Optional, Dict, Any
from datetime import datetime
import os

class VaultAPI:
    def __init__(self):
        self.client = hvac.Client(
            url=os.getenv('VAULT_ADDR', 'http://127.0.0.1:8200'),
            token=os.getenv('VAULT_TOKEN')
        )
        self._verify_vault_health()

    def _verify_vault_health(self) -> bool:
        """Verify Vault is healthy and manifest exists."""
        try:
            # Check Vault is unsealed and accessible
            url = f"{self.client.url}/v1/sys/health"
            response = self.client.session.get(url)
            if response.status_code != 200:
                raise Exception(f"Vault health check failed with status {response.status_code}")
            health = response.json()
            if not health.get('initialized') or health.get('sealed'):
                raise Exception("Vault is not initialized or is sealed")

            # Verify manifest exists and is readable
            manifest = self.get_manifest()
            if not manifest:
                raise Exception("Vault manifest not found")

            return True
        except Exception as e:
            raise Exception(f"Vault health check failed: {str(e)}")

    def get_manifest(self) -> Dict[str, Any]:
        """Get the current Vault manifest."""
        try:
            result = self.client.secrets.kv.v2.read_secret_version(
                path='manifest',
                mount_point='kv'
            )
            return result['data']['data']
        except Exception as e:
            raise Exception(f"Failed to read Vault manifest: {str(e)}")

    def get_credential(self, service_name: str, field: str = None) -> Optional[str]:
        """Get a credential from Vault with proper access pattern."""
        try:
            # First verify manifest to ensure Vault health
            manifest = self.get_manifest()
            
            # Check if service exists in manifest
            if service_name not in manifest:
                raise Exception(f"Service {service_name} not found in Vault manifest")

            # Read the actual credential
            result = self.client.secrets.kv.v2.read_secret_version(
                path=service_name,
                mount_point='kv'
            )

            if field:
                return result['data']['data'].get(field)
            return result['data']['data']

        except Exception as e:
            raise Exception(f"Failed to get credential for {service_name}: {str(e)}")

    def update_manifest(self, service_name: str, data: Dict[str, Any]) -> None:
        """Update the manifest when adding new credentials."""
        try:
            manifest = self.get_manifest()
            manifest[service_name] = data
            manifest['last_updated'] = datetime.utcnow().isoformat()

            self.client.secrets.kv.v2.create_or_update_secret(
                path='manifest',
                secret=manifest,
                mount_point='kv'
            )
        except Exception as e:
            raise Exception(f"Failed to update manifest: {str(e)}")

# Singleton instance
_vault_api = None

def get_vault_api() -> VaultAPI:
    """Get or create the VaultAPI singleton instance."""
    global _vault_api
    if _vault_api is None:
        _vault_api = VaultAPI()
    return _vault_api

