"""
Configuration management for the GitHub synchronization system.

This module handles configuration settings, environment-specific configurations,
and secure credential management for the GitHub sync system.
"""

from dataclasses import dataclass
from enum import Enum
from pathlib import Path
from typing import Dict, Optional
import logging
import os
import yaml
from cryptography.fernet import Fernet

class Environment(Enum):
    """Supported environment types."""
    DEVELOPMENT = "development"
    STAGING = "staging"
    PRODUCTION = "production"

@dataclass
class SyncConfig:
    """Configuration settings for the GitHub sync system."""

    # Repository settings
    repository: str
    branch: str
    repository_path: Path
    
    # GitHub authentication
    github_token: str
    
    # Sync settings
    sync_interval: int = 300  # seconds
    push_retries: int = 3
    auto_commit: bool = True
    
    # File monitoring
    watch_patterns: list[str] = None
    ignore_patterns: list[str] = None
    
    # Logging
    log_level: int = logging.INFO
    log_path: Path = None

    @classmethod
    def from_env(cls, env: Environment = Environment.DEVELOPMENT) -> 'SyncConfig':
        """
        Create configuration from environment settings.

        Args:
            env: Environment to load configuration for

        Returns:
            Populated configuration object

        Raises:
            ValueError: If required environment variables are missing
        """
        config_path = Path(os.getenv('SYNC_CONFIG_PATH', 'config.yml'))
        if not config_path.exists():
            raise ValueError(f"Config file not found: {config_path}")

        with open(config_path) as f:
            config = yaml.safe_load(f)

        # Load environment-specific settings
        env_config = config.get(env.value, {})
        config.update(env_config)

        # Validate required settings
        required = {'repository', 'branch', 'repository_path'}
        missing = required - set(config.keys())
        if missing:
            raise ValueError(f"Missing required config: {missing}")

        return cls(
            repository=config['repository'],
            branch=config['branch'],
            repository_path=Path(config['repository_path']),
            github_token=cls._load_github_token(),
            sync_interval=config.get('sync_interval', 300),
            push_retries=config.get('push_retries', 3),
            auto_commit=config.get('auto_commit', True),
            watch_patterns=config.get('watch_patterns', ['*']),
            ignore_patterns=config.get('ignore_patterns', []),
            log_level=cls._parse_log_level(config.get('log_level', 'INFO')),
            log_path=Path(config.get('log_path', 'logs'))
        )

    @staticmethod
    def _load_github_token() -> str:
        """
        Securely load GitHub token from environment or keyring.

        Returns:
            GitHub authentication token

        Raises:
            ValueError: If GitHub token cannot be loaded
        """
        # Try environment variable first
        token = os.getenv('GITHUB_TOKEN')
        if token:
            return token

        # Try secure storage
        try:
            import keyring
            token = keyring.get_password('github', 'sync_token')
            if token:
                return token
        except ImportError:
            pass

        raise ValueError("GitHub token not found in environment or keyring")

    @staticmethod
    def _parse_log_level(level: str) -> int:
        """
        Parse logging level from string.

        Args:
            level: String representation of log level

        Returns:
            Logging level constant
        """
        levels = {
            'DEBUG': logging.DEBUG,
            'INFO': logging.INFO,
            'WARNING': logging.WARNING,
            'ERROR': logging.ERROR,
            'CRITICAL': logging.CRITICAL
        }
        return levels.get(level.upper(), logging.INFO)

class SecureTokenManager:
    """Secure management of authentication tokens and credentials."""

    def __init__(self):
        """Initialize the secure token manager."""
        self.key = self._load_or_generate_key()
        self.cipher_suite = Fernet(self.key)

    def _load_or_generate_key(self) -> bytes:
        """
        Load or generate encryption key.

        Returns:
            Encryption key
        """
        key_file = Path('.sync_key')
        if key_file.exists():
            return key_file.read_bytes()
        
        key = Fernet.generate_key()
        key_file.write_bytes(key)
        return key

    def encrypt_token(self, token: str) -> bytes:
        """
        Encrypt a token.

        Args:
            token: Token to encrypt

        Returns:
            Encrypted token
        """
        return self.cipher_suite.encrypt(token.encode())

    def decrypt_token(self, encrypted_token: bytes) -> str:
        """
        Decrypt a token.

        Args:
            encrypted_token: Token to decrypt

        Returns:
            Decrypted token
        """
        return self.cipher_suite.decrypt(encrypted_token).decode()

class ConfigurationManager:
    """Manage configuration across different environments."""

    def __init__(self, config_path: Optional[Path] = None):
        """
        Initialize the configuration manager.

        Args:
            config_path: Path to configuration file
        """
        self.config_path = config_path or Path('config.yml')
        self.current_config: Optional[SyncConfig] = None
        self.token_manager = SecureTokenManager()

    def load_config(self, env: Environment = Environment.DEVELOPMENT) -> SyncConfig:
        """
        Load configuration for specified environment.

        Args:
            env: Environment to load configuration for

        Returns:
            Loaded configuration
        """
        self.current_config = SyncConfig.from_env(env)
        return self.current_config

    def save_config(self, config: Dict) -> None:
        """
        Save configuration to file.

        Args:
            config: Configuration dictionary to save
        """
        with open(self.config_path, 'w') as f:
            yaml.safe_dump(config, f)

    def update_github_token(self, token: str) -> None:
        """
        Update GitHub token in secure storage.

        Args:
            token: New GitHub token
        """
        try:
            import keyring
            keyring.set_password('github', 'sync_token', token)
        except ImportError:
            # Fall back to encrypted file storage
            encrypted = self.token_manager.encrypt_token(token)
            Path('.github_token').write_bytes(encrypted)

    def validate_config(self, config: Dict) -> bool:
        """
        Validate configuration settings.

        Args:
            config: Configuration to validate

        Returns:
            True if configuration is valid
        """
        required_keys = {'repository', 'branch', 'repository_path'}
        return all(key in config for key in required_keys)

