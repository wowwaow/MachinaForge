import os
import subprocess
from pathlib import Path

def setup_ssh():
    try:
        # Ensure .ssh directory exists with correct permissions
        ssh_dir = Path.home() / '.ssh'
        ssh_dir.mkdir(mode=0o700, exist_ok=True)
        
        # Create SSH config file if it doesn't exist
        config_file = ssh_dir / 'config'
        if not config_file.exists():
            config_file.touch(mode=0o600)
        
        # Set up Hetzner config
        config_content = """
# Hetzner Cloud Server
Host hetzner
    HostName ${HETZNER_IP}
    User root
    IdentityFile ~/.ssh/hetzner_key
    StrictHostKeyChecking no
"""
        
        # Write config
        with open(config_file, 'a') as f:
            f.write(config_content)
        
        # Copy SSH key from vault
        vault_key = Path('vault/SSH_Keys/hetzner_key')
        if vault_key.exists():
            target_key = ssh_dir / 'hetzner_key'
            subprocess.run(['cp', str(vault_key), str(target_key)])
            subprocess.run(['chmod', '600', str(target_key)])
            print("SSH key installed successfully")
        else:
            print("SSH key not found in vault")
            
        return True
        
    except Exception as e:
        print(f"Error setting up SSH: {str(e)}")
        return False

if __name__ == '__main__':
    setup_ssh()

