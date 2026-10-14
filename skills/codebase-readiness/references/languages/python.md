# Python — Language-Specific Assessment Criteria

## Language Classification
- **Tier:** gradually-typed
- **Primary safety mechanism:** Optional type annotations enforced via mypy/pyright, plus runtime validation via Pydantic
- **Key principle:** Python supports a spectrum from untyped to fully annotated; assess where the codebase falls on that spectrum and whether enforcement exists in CI.

## Type Safety
### What to Examine
- Type annotation density in source files (function signatures, variable annotations)
- mypy or pyright configuration and CI enforcement
- Pydantic usage for runtime validation of inputs and data models
- py.typed marker file (indicates library exports type information)
- Use of typing module constructs: Optional, Union, List, Dict, TypeVar, Protocol

### Evidence Commands
```bash
echo "=== Type annotation density (sample) ==="
find . -name "*.py" 2>/dev/null | grep -v node_modules | grep -v .git | grep -v test | grep -v __pycache__ | head -5 \
  | xargs grep -l "def.*->.*:\|: str\|: int\|: Optional\|: List" 2>/dev/null | wc -l

echo "=== mypy / pyright config ==="
ls mypy.ini .mypy.ini pyproject.toml 2>/dev/null
grep "\[tool.mypy\]\|\[mypy\]" pyproject.toml mypy.ini .mypy.ini 2>/dev/null | head -5
grep -r "pyright\|pyrightconfig" . 2>/dev/null | grep -v node_modules | grep -v .git | head -5

echo "=== Pydantic usage ==="
grep -r "pydantic" requirements*.txt pyproject.toml setup.py setup.cfg 2>/dev/null | head -3

echo "=== py.typed marker ==="
find . -name "py.typed" 2>/dev/null | grep -v node_modules | grep -v .git | head -3

echo "=== CI enforcement ==="
grep -r "mypy\|pyright" .github/ .circleci/ .buildkite/ 2>/dev/null | head -5
```

### Scoring Criteria
- **0-20**: No type annotations, no mypy/pyright config
- **21-40**: <20% of functions annotated, mypy not enforced in CI
- **41-60**: 20-50% of functions annotated, mypy in CI but not blocking
- **61-80**: >50% annotated, mypy enforced in CI, Pydantic for critical inputs
- **81-100**: >80% annotated, mypy strict mode in CI, comprehensive Pydantic models, py.typed marker

### Language-Specific Notes
- Python's gradual typing means you should look at trajectory — is the codebase moving toward more annotations?
- Pydantic is the dominant runtime validation pattern in modern Python; its presence is a strong signal.
- mypy strict mode (`--strict` flag or `strict = true` in config) is a significantly higher bar than default mypy.

## Test Foundation
### Tooling & Detection
- **Framework:** pytest (pytest.ini, pyproject.toml [tool.pytest], conftest.py)
- **Coverage:** pytest-cov, coverage.py ([tool.coverage] in pyproject.toml)
- **Mutation testing:** mutmut, cosmic-ray
- **Property-based testing:** Hypothesis

### Evidence Commands
```bash
echo "=== Test framework ==="
ls pytest.ini conftest.py 2>/dev/null
grep "\[tool.pytest\]" pyproject.toml 2>/dev/null

echo "=== Coverage config ==="
grep -r "pytest-cov\|coverage" requirements*.txt pyproject.toml setup.py 2>/dev/null | head -5
grep "\[tool.coverage\]" pyproject.toml 2>/dev/null

echo "=== Mutation testing ==="
grep -r "mutmut\|cosmic-ray" requirements*.txt pyproject.toml 2>/dev/null | head -3

echo "=== Property-based testing ==="
grep -r "hypothesis" requirements*.txt pyproject.toml 2>/dev/null | head -3

echo "=== Skipped tests ==="
grep -r "pytest.mark.skip\|@pytest.mark.skipif\|@unittest.skip" --include="*.py" . 2>/dev/null | grep -v .git | grep -v __pycache__ | wc -l

echo "=== Mock density ==="
grep -r "mock.patch\|MagicMock\|unittest.mock\|@patch" --include="*.py" . 2>/dev/null | grep -v .git | grep -v __pycache__ | wc -l

echo "=== Test retry ==="
grep -r "pytest-rerunfailures\|flaky" requirements*.txt pyproject.toml 2>/dev/null | head -3
```

### Scoring Notes
- **Skip patterns:** `pytest.mark.skip`, `@pytest.mark.skipif`, `@unittest.skip`
- **Mock indicators:** `unittest.mock`, `mock.patch`, `MagicMock`, `@patch`
- **Retry plugins:** pytest-rerunfailures, flaky — presence may indicate flaky test tolerance
- Hypothesis (property-based testing) is a strong positive signal in Python codebases

## Feedback Loops
### Tooling
- **Pre-commit:** .pre-commit-config.yaml (pre-commit framework)
- **Parallel test runner:** pytest-xdist (`-n auto` flag)
- **Security scanners:** Bandit (static security analysis), Safety (dependency vulnerabilities)

### Evidence Commands
```bash
ls .pre-commit-config.yaml 2>/dev/null
grep -r "pytest-xdist\|xdist" requirements*.txt pyproject.toml 2>/dev/null | head -3
grep -r "bandit\|safety" .github/ .circleci/ .buildkite/ requirements*.txt pyproject.toml 2>/dev/null | head -5
```

## Code Clarity
### Conventions
- **Extensions:** .py
- **Idiomatic file size:** Python modules should be focused; large files (>300 lines) warrant review
- **Naming:** snake_case for files, functions, variables; CamelCase for classes
- **File organization:** One module per concern; `__init__.py` files define package boundaries

## Consistency & Conventions
### Tooling
- **Linter:** Flake8, Ruff (modern, fast replacement)
- **Formatter:** Black (opinionated), isort (import sorting)
- **Configuration:** pyproject.toml sections: [tool.ruff], [tool.flake8], [tool.black], [tool.isort]

### Evidence Commands
```bash
echo "=== Linter config ==="
grep -r "\[tool.ruff\]\|\[tool.flake8\]" pyproject.toml 2>/dev/null | head -5
ls .flake8 setup.cfg 2>/dev/null
grep -r "ruff\|flake8" .github/ .circleci/ .buildkite/ 2>/dev/null | head -5

echo "=== Formatter config ==="
grep -r "\[tool.black\]\|\[tool.isort\]" pyproject.toml 2>/dev/null | head -5
grep -r "black\|isort" .github/ .circleci/ .buildkite/ 2>/dev/null | head -5
ls .isort.cfg 2>/dev/null
```

## Architecture
### Framework Conventions
- **Django:** apps/ structure, urls.py, views.py, models.py, admin.py per app
- **Flask:** blueprints for modular organization
- **FastAPI:** routers, dependency injection
- **General Python:** src/ layout, packages with `__init__.py`

### Evidence Commands
```bash
echo "=== Django structure ==="
find . -name "urls.py" -o -name "views.py" -o -name "admin.py" 2>/dev/null | grep -v .git | grep -v __pycache__ | head -10

echo "=== Flask blueprints ==="
grep -r "Blueprint" --include="*.py" . 2>/dev/null | grep -v .git | grep -v __pycache__ | head -5

echo "=== Package structure ==="
find . -name "__init__.py" -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/__pycache__/*" 2>/dev/null | head -15

echo "=== Source layout ==="
ls src/ 2>/dev/null && find src/ -type d 2>/dev/null | head -15
```

### Co-Change Notes
- Django model + migration co-changes are expected (same as Rails)
- Django urls.py + views.py co-changes are expected
- settings.py high churn is expected in active Django projects

## Change Safety
### Tooling
- **Feature flags:** Custom implementations, django-waffle, flagsmith
- **Migrations:** Django migrations (app/migrations/), Alembic (for SQLAlchemy)

### Evidence Commands
```bash
echo "=== Feature flags ==="
grep -r "waffle\|flagsmith\|feature_flag\|feature_toggle" --include="*.py" . 2>/dev/null | grep -v test | grep -v .git | wc -l

echo "=== Django migrations ==="
find . -path "*/migrations/*.py" -not -name "__init__.py" 2>/dev/null | grep -v .git | wc -l

echo "=== Alembic ==="
ls alembic.ini 2>/dev/null
find . -name "alembic" -type d 2>/dev/null | head -3
```
