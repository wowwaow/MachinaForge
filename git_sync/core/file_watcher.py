"""
File system monitoring and change detection for the MachinaForge system.

This module provides real-time file system monitoring with intelligent
filtering and dependency tracking capabilities.
"""

import asyncio
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Set, Callable
import logging
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler, FileSystemEvent

logger = logging.getLogger(__name__)

class FileChangeHandler(FileSystemEventHandler):
    """Handle file system events with intelligent filtering."""

    def __init__(self, callback: Callable[[FileSystemEvent], None],
                 ignore_patterns: Set[str]):
        """
        Initialize the file change handler.

        Args:
            callback: Function to call when valid changes are detected
            ignore_patterns: Set of glob patterns to ignore
        """
        self.callback = callback
        self.ignore_patterns = ignore_patterns
        self._last_events: Dict[str, datetime] = {}

    def on_any_event(self, event: FileSystemEvent) -> None:
        """
        Handle any file system event.

        Args:
            event: The file system event to process
        """
        if self._should_process_event(event):
            self._last_events[event.src_path] = datetime.now()
            self.callback(event)

    def _should_process_event(self, event: FileSystemEvent) -> bool:
        """
        Determine if an event should be processed based on filtering rules.

        Args:
            event: The file system event to evaluate

        Returns:
            bool: True if the event should be processed
        """
        # Ignore temporary files and specific patterns
        path = Path(event.src_path)
        
        # Check against ignore patterns
        if any(path.match(pattern) for pattern in self.ignore_patterns):
            return False

        # Ignore temporary files
        if path.name.startswith('.') or path.name.endswith('~'):
            return False

        # Implement debouncing
        last_event_time = self._last_events.get(event.src_path)
        if last_event_time:
            time_diff = (datetime.now() - last_event_time).total_seconds()
            if time_diff < 1.0:  # Debounce threshold
                return False

        return True

class FileWatcher:
    """Monitor file system changes with intelligent filtering and dependency tracking."""

    def __init__(self, path: Path):
        """
        Initialize the file watcher.

        Args:
            path: Root path to monitor for changes
        """
        self.path = path
        self.observer = Observer()
        self.dependencies: Dict[str, Set[str]] = {}
        self.ignore_patterns: Set[str] = {
            "*.pyc",
            "*.pyo",
            "*.pyd",
            "*.so",
            "*.dylib",
            "*.dll",
            "__pycache__",
            ".git",
            ".idea",
            ".vscode",
            "*.swp",
            "*.swo",
            "node_modules",
            "venv",
            ".env"
        }
        self._setup_logging()

    def start_monitoring(self) -> None:
        """Start monitoring file system changes."""
        handler = FileChangeHandler(self._handle_change, self.ignore_patterns)
        self.observer.schedule(handler, str(self.path), recursive=True)
        self.observer.start()
        logger.info(f"Started monitoring changes in {self.path}")

    def stop_monitoring(self) -> None:
        """Stop monitoring file system changes."""
        if self.observer.is_alive():
            self.observer.stop()
            self.observer.join()
            logger.info("Stopped file monitoring")

    def add_dependency(self, source: str, target: str) -> None:
        """
        Add a file dependency relationship.

        Args:
            source: Source file path
            target: Target file path that depends on source
        """
        if source not in self.dependencies:
            self.dependencies[source] = set()
        self.dependencies[source].add(target)
        logger.debug(f"Added dependency: {source} -> {target}")

    def get_dependencies(self, file_path: str) -> Set[str]:
        """
        Get all files that depend on the given file.

        Args:
            file_path: Path to check dependencies for

        Returns:
            Set of file paths that depend on the given file
        """
        return self.dependencies.get(file_path, set())

    def _handle_change(self, event: FileSystemEvent) -> None:
        """
        Handle a file system change event.

        Args:
            event: The file system event to handle
        """
        try:
            path = Path(event.src_path)
            logger.debug(f"Detected change in {path}")

            # Process dependencies
            affected_files = self.get_dependencies(str(path))
            if affected_files:
                logger.info(f"Change in {path} affects: {affected_files}")
                self._notify_dependency_changes(path, affected_files)

        except Exception as e:
            logger.error(f"Error handling file change: {e}")

    def _notify_dependency_changes(self, 
                                 source: Path,
                                 affected_files: Set[str]) -> None:
        """
        Notify about changes in dependent files.

        Args:
            source: Source file that changed
            affected_files: Set of files affected by the change
        """
        # TODO: Implement notification system for dependency changes
        pass

    def analyze_dependencies(self, file_path: str) -> Set[str]:
        """
        Analyze and discover file dependencies.

        Args:
            file_path: Path to analyze for dependencies

        Returns:
            Set of file paths that are dependencies
        """
        # TODO: Implement intelligent dependency analysis
        return set()

    def _setup_logging(self) -> None:
        """Configure logging for the file watcher."""
        handler = logging.FileHandler("file_watcher.log")
        handler.setFormatter(
            logging.Formatter(
                '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
            )
        )
        logger.addHandler(handler)
        logger.setLevel(logging.INFO)

    def __del__(self) -> None:
        """Cleanup resources on object destruction."""
        self.stop_monitoring()

