# PHP — Language-Specific Assessment Criteria

## Language Classification
- **Tier:** dynamically-typed (with strong gradual typing support in PHP 8.x)
- **Primary safety mechanism:** Test coverage combined with static analysis (PHPStan/Psalm) and runtime validation (Form Requests, Eloquent casts)
- **Key principle:** PHP 8.x has robust type declarations, enums, and readonly properties. PHPStan/Larastan at high levels provides safety approaching static typing. Do NOT penalize for the absence of a compiled type system — assess the actual enforcement mechanisms in place.

## Type Safety
### What to Examine
- PHPStan or Psalm configuration level and CI enforcement
- Larastan extension for Laravel-specific analysis (model properties, query builders, etc.)
- PHP type declarations: return types, parameter types, typed properties, union types
- `declare(strict_types=1)` adoption across the codebase
- Eloquent model casts and validation rules
- Form Request validation classes for controller input validation
- PHP 8.1+ Enums for domain modeling
- Data Transfer Objects (DTOs) via libraries like spatie/laravel-data or custom classes
- Database-level constraints in migrations (nullable, unique, foreign, constrained, check)

### Evidence Commands
```bash
echo "=== PHPStan / Psalm config ==="
ls phpstan.neon phpstan.neon.dist psalm.xml psalm.xml.dist 2>/dev/null
cat phpstan.neon 2>/dev/null || cat phpstan.neon.dist 2>/dev/null | head -20

echo "=== PHPStan level ==="
grep -i "level" phpstan.neon phpstan.neon.dist 2>/dev/null

echo "=== Larastan ==="
grep -i "larastan" phpstan.neon phpstan.neon.dist composer.json 2>/dev/null

echo "=== PHPStan baseline size ==="
find . -name "phpstan-baseline*" -not -path "*/vendor/*" 2>/dev/null | xargs wc -l 2>/dev/null

echo "=== CI enforcement ==="
grep -r "phpstan\|psalm\|larastan" .github/ .circleci/ .buildkite/ 2>/dev/null | head -5

echo "=== strict_types adoption ==="
find app/ -name "*.php" 2>/dev/null | xargs grep -l "declare(strict_types=1)" 2>/dev/null | wc -l
find app/ -name "*.php" 2>/dev/null | wc -l

echo "=== Return type declarations (sample) ==="
find app/ -name "*.php" -not -path "*/vendor/*" 2>/dev/null | head -20 | xargs grep -c "function.*):.*" 2>/dev/null | awk -F: '{sum+=$2} END {print "Functions with return types:", sum}'

echo "=== Eloquent model validations & casts ==="
find app/Models -name "*.php" 2>/dev/null | xargs grep -l "casts\|fillable\|guarded" 2>/dev/null | wc -l

echo "=== Form Request classes ==="
find app/Http/Requests -name "*.php" 2>/dev/null | wc -l

echo "=== PHP 8.1+ Enums ==="
find app/ -name "*.php" -path "*/Enums/*" 2>/dev/null | wc -l

echo "=== DTOs (spatie/laravel-data or custom) ==="
find app/ -name "*.php" -path "*/Data/*" -o -name "*.php" -path "*/DTO/*" -o -name "*.php" -path "*/DataTransferObjects/*" 2>/dev/null | grep -v vendor | wc -l
grep -i "spatie/laravel-data" composer.json 2>/dev/null

echo "=== Database constraints in migrations ==="
find database/migrations -name "*.php" 2>/dev/null | xargs grep -c "nullable\|unique\|foreign\|references\|constrained\|check" 2>/dev/null | awk -F: '{sum+=$2} END {print "Constraint annotations:", sum}'

echo "=== Contracts / Interfaces ==="
find app/Contracts app/Interfaces -name "*.php" 2>/dev/null | wc -l
```

### Scoring Criteria
- **0-20**: No PHPStan/Psalm, no type declarations, no Form Requests, no validations
- **21-40**: Basic Eloquent validations only, no static analysis, inconsistent type hints
- **41-60**: PHPStan configured (level 4-6) OR consistent type declarations + Form Requests. Not enforced in CI.
- **61-80**: PHPStan level 7-8 enforced in CI, Form Requests for validation, typed properties, Enums for domain modeling, database constraints present
- **81-100**: PHPStan level 8+ enforced in CI with small baseline, strict_types pervasive (>70%), comprehensive Enums, DTOs, contracts, and Form Requests. Database constraints disciplined.

### Language-Specific Notes
- PHP 8.x has native type declarations (return types, parameter types, union types, intersection types, readonly properties). These provide meaningful safety even without PHPStan.
- PHPStan level 8+ with Larastan provides safety comparable to TypeScript strict mode for Laravel apps.
- A large PHPStan baseline file (>1000 lines) may indicate the tool is configured but errors are suppressed rather than resolved. Penalize proportionally.
- `declare(strict_types=1)` changes PHP's type coercion behavior — its presence is a strong signal of intentional type discipline.
- Enums (PHP 8.1+) are a key domain modeling tool. High enum count relative to model count signals good type expressiveness.
- Do NOT penalize for absence of Psalm if PHPStan is present — they serve the same purpose. Penalize only if neither exists.

## Test Foundation
### Tooling & Detection
- **Framework:** Pest (tests/ directory, `uses()`, `it()`, `test()`, `expect()`) or PHPUnit (tests/ directory, `*Test.php` files)
- **Coverage:** PHPUnit built-in coverage, pcov, or Xdebug coverage driver
- **Mutation testing:** Infection PHP
- **Property-based testing:** Not common in PHP ecosystem
- **Browser testing:** Laravel Dusk

### Evidence Commands
```bash
echo "=== Test framework ==="
ls phpunit.xml phpunit.xml.dist 2>/dev/null
grep -r "pestphp/pest" composer.json 2>/dev/null && echo "Pest detected"

echo "=== Test file count ==="
find tests/ -name "*.php" -type f 2>/dev/null | wc -l

echo "=== Test organization ==="
find tests/ -type d 2>/dev/null | head -15

echo "=== Coverage config ==="
grep -A5 "coverage" phpunit.xml phpunit.xml.dist 2>/dev/null | head -15
grep -r "coverage\|--coverage" .github/ .circleci/ .buildkite/ 2>/dev/null | head -5

echo "=== Mutation testing ==="
grep -i "infection" composer.json 2>/dev/null

echo "=== Skipped tests ==="
grep -r "skip\|markTestSkipped\|markTestIncomplete\|->skip()" --include="*.php" tests/ 2>/dev/null | wc -l

echo "=== Mock/stub density ==="
grep -r "mock\|Mockery\|createMock\|getMockBuilder\|spy\(\|fake\(\|Mock::" --include="*.php" tests/ 2>/dev/null | wc -l

echo "=== Browser tests (Dusk) ==="
find tests/ -path "*/Browser/*" -name "*.php" 2>/dev/null | wc -l
grep -i "laravel/dusk" composer.json 2>/dev/null

echo "=== Test retry plugins ==="
grep -i "retry\|flaky" composer.json 2>/dev/null | head -3

echo "=== Factory files ==="
find database/factories -name "*.php" 2>/dev/null | wc -l
```

### Scoring Notes
- **Skip patterns:** `->skip()` (Pest), `markTestSkipped()`, `markTestIncomplete()` (PHPUnit)
- **Mock indicators:** `Mockery::mock`, `createMock`, `getMockBuilder`, `spy()`, `fake()`, `Mock::`
- **Test pyramid:** Feature tests (tests/Feature/) are integration-level in Laravel — they hit the database via `RefreshDatabase`. Unit tests (tests/Unit/) are isolated.
- Laravel Feature tests dominating over Unit tests is normal and appropriate — do not penalize this ratio.
- Factories presence (database/factories/) is a strong signal of reproducible test data.

## Feedback Loops
### Tooling
- **Pre-commit:** Husky, Lefthook, Captain Hook
- **Parallel test runner:** `php artisan test --parallel` (built into Laravel), paratest
- **Security scanners:** PHPStan (static analysis), Enlightn (Laravel security), composer audit (dependency vulnerabilities)
- **Code formatter:** Laravel Pint (pint.json), PHP-CS-Fixer (.php-cs-fixer.php)

### Evidence Commands
```bash
echo "=== Pre-commit hooks ==="
ls .husky/ 2>/dev/null && ls .husky/
ls lefthook.yml .pre-commit-config.yaml captainhook.json 2>/dev/null

echo "=== Parallel testing ==="
grep -r "parallel\|paratest" .github/ composer.json 2>/dev/null | head -5

echo "=== Security scanning ==="
grep -r "phpstan\|enlightn\|security\|composer.*audit" .github/ .circleci/ .buildkite/ 2>/dev/null | head -5

echo "=== Dependency auditing ==="
ls .github/dependabot.yml 2>/dev/null && echo "Dependabot configured"
ls renovate.json .renovaterc 2>/dev/null && echo "Renovate configured"
grep -r "composer.*audit" .github/ 2>/dev/null | head -3

echo "=== Laravel Sail / Docker ==="
ls docker-compose*.yml Dockerfile .devcontainer/ 2>/dev/null
grep -r "sail" docker-compose*.yml 2>/dev/null | head -3
```

## Code Clarity
### Conventions
- **Extensions:** .php
- **Idiomatic file size:** PHP/Laravel files should be focused. Controllers and models exceeding 300 lines are a smell. Service classes exceeding 200 lines warrant review.
- **Naming:** PascalCase for classes, camelCase for methods/properties, snake_case for database columns and config keys
- **File organization:** One class per file, PSR-4 autoloading. Filename must match class name.
- **Laravel convention:** Controllers in `app/Http/Controllers/`, Models in `app/Models/`, Services in `app/Services/`, etc.

## Consistency & Conventions
### Tooling
- **Linter/Static analysis:** PHPStan (phpstan.neon), Larastan (Laravel extension), Psalm (psalm.xml)
- **Formatter:** Laravel Pint (pint.json, wraps PHP-CS-Fixer), PHP-CS-Fixer (.php-cs-fixer.php)
- **Frontend:** Prettier (.prettierrc), ESLint (.eslintrc*)

### Evidence Commands
```bash
echo "=== PHP formatting config ==="
ls pint.json .php-cs-fixer.php .php-cs-fixer.dist.php 2>/dev/null
cat pint.json 2>/dev/null | head -20

echo "=== Static analysis config ==="
ls phpstan.neon phpstan.neon.dist psalm.xml 2>/dev/null

echo "=== Frontend lint/format ==="
ls .prettierrc* .eslintrc* biome.json 2>/dev/null

echo "=== CI enforcement ==="
grep -r "pint\|php-cs-fixer\|phpstan\|psalm\|prettier\|eslint" .github/ .circleci/ .buildkite/ 2>/dev/null | head -10

echo "=== Custom PHPStan rules ==="
find . -name "*.php" -path "*Rule*" -path "*PHPStan*" 2>/dev/null | grep -v vendor | head -5
find . -name "*.php" -path "*rules*" -path "*phpstan*" 2>/dev/null | grep -v vendor | head -5
```

## Architecture
### Framework Conventions
- **Laravel MVC:** app/Models, app/Http/Controllers, app/Services, resources/views (or Inertia Pages)
- **Domain directories:** app/Domain/, app/Actions/, app/Services/ with domain subdirectories
- **Service Providers as boundaries:** Custom service providers can signal domain-level modularity
- **Laravel Packages / Modules:** nwidart/laravel-modules or custom package structure for domain boundaries
- **Route files:** routes/web.php, routes/api.php, routes/console.php — large route files signal insufficient domain separation

### Evidence Commands
```bash
echo "=== App directory structure ==="
ls app/ 2>/dev/null
find app/ -type d -maxdepth 2 2>/dev/null | sort

echo "=== Controller sizes ==="
find app/Http/Controllers -name "*.php" 2>/dev/null | xargs wc -l 2>/dev/null | sort -rn | head -15

echo "=== Service layer ==="
find app/ -type d \( -name "Services" -o -name "Actions" -o -name "Jobs" -o -name "Listeners" -o -name "Observers" -o -name "Domain" \) 2>/dev/null

echo "=== Service / Action file counts ==="
find app/Services -name "*.php" 2>/dev/null | wc -l
find app/Actions -name "*.php" 2>/dev/null | wc -l

echo "=== Model count ==="
find app/Models -name "*.php" 2>/dev/null | wc -l

echo "=== Route file sizes ==="
wc -l routes/*.php 2>/dev/null

echo "=== Service Providers ==="
find app/Providers -name "*.php" 2>/dev/null | wc -l

echo "=== Frontend structure (Inertia) ==="
find resources/js/Pages -type d -maxdepth 3 2>/dev/null | sort | head -20

echo "=== Nested CLAUDE.md files ==="
find . -name "CLAUDE.md" -not -path "./vendor/*" -not -path "./node_modules/*" 2>/dev/null
```

### Co-Change Notes
- **Expected Laravel co-changes (NOT bad coupling):**
  - Model + migration
  - Controller + Form Request
  - Controller + Inertia Page component
  - Model + Factory
- **High churn files to exclude from coupling analysis:**
  - routes/web.php, routes/api.php — modified for most feature additions
  - bootstrap/app.php — modified for middleware and routing changes
  - config/horizon.php — modified for queue tuning
  - Locale files (lang/) — updated for most user-facing changes
- These expected co-changes should NOT penalize the architecture score.

## Change Safety
### Tooling
- **Feature flags:** Laravel Pennant (native), custom implementations
- **Migrations:** database/migrations/ directory (Laravel migrations)
- **Validation in migrations:** Check for nullable, unique, foreign key, and check constraints

### Evidence Commands
```bash
echo "=== Feature flags (Pennant) ==="
grep -r "Feature::\|pennant" --include="*.php" app/ 2>/dev/null | grep -v vendor | wc -l
find app/ -path "*Features*" -name "*.php" 2>/dev/null | wc -l

echo "=== Migration count ==="
find database/migrations -name "*.php" 2>/dev/null | wc -l

echo "=== Destructive migration operations ==="
find database/migrations -name "*.php" 2>/dev/null | xargs grep -l "dropColumn\|dropTable\|removeColumn\|drop(" 2>/dev/null | wc -l

echo "=== Reversible migrations (down method) ==="
find database/migrations -name "*.php" 2>/dev/null | xargs grep -l "function down" 2>/dev/null | wc -l

echo "=== Migration constraints ==="
find database/migrations -name "*.php" 2>/dev/null | xargs grep -c "unique\|foreign\|constrained\|nullable\|check" 2>/dev/null | awk -F: '{sum+=$2} END {print "Total constraint references:", sum}'
```
