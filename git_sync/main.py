#!/usr/bin/env python3
"""
Main entry point for the MachinaForge GitHub Integration & Auto-Update System.

This script provides command-line interface and orchestration for the
GitHub synchronization system.
"""

import argparse
import asyncio
import logging
import sys
from pathlib import Path
from typing import Optional

from config.sync_config import ConfigurationManager, Environment, SyncConfig
from core.sync_engine import GitHubSyncEngine
from core.documentation_manager import DocumentationManager

logger = logging.getLogger(__name__)

class SyncManager:
    """Orchestrate the GitHub synchronization system."""

    def __init__(self, config_path: Optional[Path] = None):
        """
        Initialize the sync manager.

        Args:
            config_path: Optional path to configuration file
        """
        self.config_manager = ConfigurationManager(config_path)
        self.sync_engine: Optional[GitHubSyncEngine] = None
        self.doc_manager: Optional[DocumentationManager] = None
        self._setup_logging()

    async def start(self, env: Environment = Environment.DEVELOPMENT) -> None:
        """
        Start the synchronization system.

        Args:
            env: Environment to run in
        """
        try:
            # Load configuration
            config = self.config_manager.load_config(env)
            
            # Initialize components
            self.sync_engine = GitHubSyncEngine(config)
            self.doc_manager = DocumentationManager(
                config.repository_path,
                config.repository_path / 'templates'
            )
            
            # Initialize sync engine
            await self.sync_engine.initialize()
            
            # Start periodic sync
            while True:
                success = await self.sync_engine.sync()
                if success:
                    await self._update_documentation()
                await asyncio.sleep(config.sync_interval)

        except Exception as e:
            logger.error(f"Failed to start sync system: {e}")
            raise

    async def _update_documentation(self) -> None:
        """Update project documentation based on recent changes."""
        try:
            changes = await self.sync_engine._analyze_local_changes()
            if changes:
                await self.doc_manager.update_readme(changes)
                await self.doc_manager.update_changelog("dev", changes)
                self.doc_manager.generate_contributor_docs()
                await self.doc_manager.generate_api_docs()
        except Exception as e:
            logger.error(f"Failed to update documentation: {e}")

    def _setup_logging(self) -> None:
        """Configure logging for the sync manager."""
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            handlers=[
                logging.StreamHandler(),
                logging.FileHandler('sync_manager.log')
            ]
        )

def parse_args() -> argparse.Namespace:
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="MachinaForge GitHub Integration & Auto-Update System"
    )
    parser.add_argument(
        "--config",
        type=Path,
        help="Path to configuration file"
    )
    parser.add_argument(
        "--env",
        type=str,
        choices=[e.value for e in Environment],
        default=Environment.DEVELOPMENT.value,
        help="Environment to run in"
    )
    return parser.parse_args()

async def main() -> None:
    """Main entry point."""
    args = parse_args()
    
    try:
        manager = SyncManager(args.config)
        await manager.start(Environment(args.env))
    except KeyboardInterrupt:
        logger.info("Shutting down sync system...")
    except Exception as e:
        logger.error(f"Sync system error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    asyncio.run(main())

