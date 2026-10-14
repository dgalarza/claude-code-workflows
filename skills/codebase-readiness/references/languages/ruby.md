# Ruby — Language-Specific Assessment Criteria

## Language Classification
- **Tier:** dynamically-typed
- **Primary safety mechanism:** Test coverage combined with contract libraries (dry-rb ecosystem)
- **Key principle:** High test coverage plus strong contracts provides safety equivalent to static typing; do NOT penalize for absence of Sorbet.

## Type Safety
### What to Examine
- Contract libraries: dry-types, dry-validation, dry-struct, dry-container
- ActiveRecord validation coverage on domain models
- Service object interface clarity: consistent `def call` signatures, typed return values via App::Result or similar pattern
- Sorbet/RBS adoption (bonus only — not required for high scores)

### Evidence Commands
```bash
echo "=== ActiveRecord Validations ==="
find app/models -name "*.rb" 2>/dev/null | xargs grep -l "validates\|validate " 2>/dev/null | wc -l

echo "=== dry-rb adoption ==="
grep -i "dry-types\|dry-validation\|dry-container\|dry-struct\|dry-rb" Gemfile 2>/dev/null

echo "=== Service object interface patterns ==="
find app/services -name "*.rb" 2>/dev/null | xargs grep -l "def call\|def self.call" 2>/dev/null | wc -l
grep -r "App::Result\|Result.success\|Result.failure\|ServiceResult" app/ 2>/dev/null | grep -v spec | wc -l

echo "=== Sorbet / RBS (advanced, bonus) ==="
ls sorbet/ 2>/dev/null && echo "Sorbet present"
grep -i "sorbet\|rbs\|steep" Gemfile 2>/dev/null
```

### Scoring Criteria
- **0-20**: No validations on domain models, no contract patterns, service interfaces inconsistent
- **21-40**: Basic ActiveRecord validations only, no contract libraries, service interfaces informal
- **41-60**: ActiveRecord validations + one dry-rb library OR consistent Result pattern
- **61-80**: dry-rb contracts across domain layer, consistent service interfaces with explicit success/failure
- **81-100**: Comprehensive contract system (dry-rb), consistent interfaces, Result pattern, Sorbet as bonus

### Language-Specific Notes
- Ruby's primary safety mechanism is test coverage. High tests + strong contracts = equivalent to TypeScript strict.
- DO NOT penalize for lack of Sorbet/RBS. These are bonus indicators, not requirements.
- Look for consistent patterns across the codebase rather than individual file adoption.

## Test Foundation
### Tooling & Detection
- **Framework:** RSpec (spec/ directory, *_spec.rb files)
- **Coverage:** SimpleCov (.simplecov file)
- **Mutation testing:** Mutant gem
- **Property-based testing:** Rantly, Faker (for data generation)

### Evidence Commands
```bash
echo "=== Coverage config ==="
ls .simplecov 2>/dev/null
grep -r "simplecov" .github/ .circleci/ .buildkite/ 2>/dev/null | head -5

echo "=== Mutation testing ==="
grep -i "mutant" Gemfile 2>/dev/null

echo "=== Skipped tests ==="
grep -r "skip\|xit\|xdescribe" --include="*_spec.rb" . 2>/dev/null | grep -v node_modules | grep -v .git | wc -l
grep -r "pending\b" --include="*_spec.rb" . 2>/dev/null | grep -v node_modules | wc -l

echo "=== Mock/stub density ==="
grep -r "allow\|stub\|double\|instance_double\|class_double" --include="*_spec.rb" . 2>/dev/null | grep -v node_modules | grep -v .git | wc -l

echo "=== Property-based testing ==="
grep -i "rantly\|hypothesis\|faker" Gemfile 2>/dev/null | head -5

echo "=== Test retry plugins ==="
grep -i "rspec-retry" Gemfile 2>/dev/null
```

### Scoring Notes
- **Skip patterns:** `skip`, `xit`, `xdescribe`, `pending`
- **Mock indicators:** `allow`, `stub`, `double`, `instance_double`, `class_double`
- **Retry plugin:** rspec-retry — presence may indicate flaky test tolerance
- High mock density relative to test count can indicate shallow testing

## Feedback Loops
### Tooling
- **Pre-commit:** lefthook (lefthook.yml)
- **Parallel test runner:** parallel_tests gem
- **Security scanners:** Brakeman (static analysis), bundle-audit (dependency vulnerabilities)

### Evidence Commands
```bash
ls lefthook.yml 2>/dev/null
grep -i "parallel_tests" Gemfile 2>/dev/null
grep -r "brakeman\|bundle-audit" .github/ .circleci/ .buildkite/ Gemfile 2>/dev/null | head -5
```

## Code Clarity
### Conventions
- **Extensions:** .rb
- **Idiomatic file size:** Ruby files tend to be shorter than JS/TS equivalents; large files (>200 lines) are a stronger smell in Ruby than in some other languages
- **Naming:** snake_case for files and methods, CamelCase for classes/modules
- **File organization:** One class per file is conventional, matching the class name to the filename

## Consistency & Conventions
### Tooling
- **Linter:** RuboCop (.rubocop.yml or .rubocop.yaml)
- **Formatter:** RuboCop (doubles as linter and formatter)
- **Custom rules:** Custom RuboCop cops for project-specific conventions

### Evidence Commands
```bash
ls .rubocop.yml .rubocop.yaml 2>/dev/null
grep -r "rubocop" .github/ .circleci/ .buildkite/ 2>/dev/null | head -5
find . -name "*.rb" -path "*cop*" -o -name "*.rb" -path "*rubocop*" 2>/dev/null | grep -v vendor | grep -v spec | head -5
```

## Architecture
### Framework Conventions
- **Rails MVC:** app/models, app/controllers, app/services, app/views
- **Rails engines as domain boundaries:** Strong signal of intentional modular architecture
- **Gemspec files in subdirectories:** Indicates extracted libraries or engine-based structure

### Evidence Commands
```bash
ls app/ 2>/dev/null && ls app/
find app/ -type d 2>/dev/null | head -20
find . -name "*.gemspec" -not -path "*/vendor/*" 2>/dev/null | head -10
find . -path "*/engines/*/lib" -type d 2>/dev/null | head -10
find . \( -name "*controller*" -o -name "*_controller.rb" \) 2>/dev/null | grep -v node_modules | grep -v .git | grep -v spec | xargs wc -l 2>/dev/null | sort -rn | head -10
```

### Co-Change Notes
- **Expected Rails co-changes (NOT bad coupling):**
  - Model + migration
  - Controller + view
  - Model + spec
- **High churn files to exclude from coupling analysis:**
  - schema.rb — regenerated on every migration
  - routes.rb — modified for most feature additions
  - Locale files (config/locales/) — updated for most user-facing changes
- These expected co-changes should NOT penalize the architecture score.

## Change Safety
### Tooling
- **Feature flags:** Flipper gem
- **Migrations:** db/migrate/ directory (Rails migrations)
- **Validation in migrations:** Check for uniqueness constraints, presence validations, and index additions

### Evidence Commands
```bash
grep -r "flipper\|feature_flag\|rollout" --include="*.rb" . 2>/dev/null | grep -v spec | grep -v test | wc -l
grep -r "validates.*uniqueness\|validates.*presence\|add_index.*unique" db/migrate/ 2>/dev/null | wc -l
```
