## Python Conventions

### Environment
- Always use virtual environments (`python -m venv .venv`)
- Pin dependencies in `requirements.txt` or use `pyproject.toml` with version constraints
- Never install packages globally for project work

### Type Safety
- Use type hints on all function signatures (Python 3.10+ syntax preferred)
- Use `ruff` for linting and `mypy` for type checking
- Prefer `dataclass` or `TypedDict` over raw dicts for structured data
- Use `Literal` types for fixed string sets

### Code Patterns
- Use pathlib.Path over os.path for file operations
- Use f-strings over .format() or % formatting
- Prefer list comprehensions over map/filter for simple transformations
- Use `contextlib.contextmanager` for resource management
- Use `logging` module, never `print()` for operational output

### Error Handling
- Define custom exception classes for domain errors
- Use `try/except` with specific exception types — never bare `except:`
- Use `with` statements for file I/O and database connections

### Security
- Never use `eval()`, `exec()`, or `pickle` with untrusted data
- Use parameterized queries for SQL (never f-strings)
- Validate all external input with Pydantic or similar
