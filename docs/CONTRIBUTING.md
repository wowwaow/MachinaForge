# 🤝 Contributing to MachinaForge

## Table of Contents
1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [Development Process](#development-process)
4. [Coding Standards](#coding-standards)
5. [Documentation Guidelines](#documentation-guidelines)
6. [Testing Requirements](#testing-requirements)
7. [Submission Process](#submission-process)

## Code of Conduct

### Our Pledge
We are committed to creating a welcoming and inclusive environment for all contributors. We expect all participants to adhere to our code of conduct:

- **Respect**: Show respect for different viewpoints and experiences
- **Openness**: Welcome feedback and constructive criticism
- **Collaboration**: Focus on what is best for the community
- **Inclusivity**: Be welcoming to newcomers and encourage participation

## Getting Started

### 1. Environment Setup
```bash
# Fork the repository
git clone https://github.com/your-username/MachinaForge.git
cd MachinaForge

# Create development branch
git checkout -b feature/your-feature-name

# Install development dependencies
pip install -r requirements-dev.txt
```

### 2. Development Environment
- Python 3.8+
- Git 2.0+
- Your favorite IDE with Python support
- Recommended: VS Code with Python extensions

## Development Process

### 1. Branch Naming
- `feature/` - For new features
- `bugfix/` - For bug fixes
- `docs/` - For documentation changes
- `test/` - For test additions or changes

### 2. Commit Messages
Follow conventional commits:
```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting
- `refactor`: Code restructuring
- `test`: Test addition/modification
- `chore`: Maintenance

### 3. Pull Request Process
1. Update documentation
2. Add/update tests
3. Run local tests
4. Create detailed PR description
5. Request review
6. Address feedback

## Coding Standards

### 1. Python Style Guide
- Follow PEP 8
- Use type hints
- Maximum line length: 88 characters
- Use descriptive variable names

### 2. Documentation
- Docstrings for all public methods
- Inline comments for complex logic
- README updates for new features
- Keep documentation up to date

### 3. Error Handling
- Use appropriate exception types
- Include error messages
- Log errors properly
- Implement proper recovery

## Documentation Guidelines

### 1. Code Documentation
```python
def process_task(task_id: str, priority: int = 1) -> bool:
    """
    Process a task with given priority.

    Args:
        task_id: Unique identifier for the task
        priority: Task priority (1-5, 1 being highest)

    Returns:
        bool: True if processing successful, False otherwise

    Raises:
        ValueError: If priority is out of range
    """
    pass
```

### 2. Markdown Standards
- Use headers appropriately
- Include code examples
- Add screenshots when relevant
- Keep content organized

## Testing Requirements

### 1. Test Coverage
- Minimum 80% coverage
- Unit tests for new features
- Integration tests for workflows
- Performance tests for critical paths

### 2. Test Structure
```python
def test_process_task():
    """Test task processing functionality."""
    # Arrange
    task_id = "test_task"
    priority = 1

    # Act
    result = process_task(task_id, priority)

    # Assert
    assert result is True
```

## Submission Process

### 1. Pre-submission Checklist
- [ ] Tests passing
- [ ] Documentation updated
- [ ] Code follows standards
- [ ] Commit messages formatted
- [ ] Branch up to date

### 2. Pull Request Template
```markdown
## Description
[Describe your changes]

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing performed

## Documentation
- [ ] Code documentation updated
- [ ] README updated
- [ ] Additional docs added
```

### 3. Review Process
1. Automated checks
2. Code review
3. Documentation review
4. Testing verification
5. Final approval

## Additional Resources

### 1. Development Tools
- Recommended IDE: VS Code
- Linting: flake8, pylint
- Formatting: black
- Type checking: mypy

### 2. Useful Commands
```bash
# Run tests
pytest

# Check coverage
coverage run -m pytest
coverage report

# Format code
black .

# Check types
mypy .

# Run linter
flake8
```

Last Updated: 2025-06-01

