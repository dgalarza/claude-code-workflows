# Go — Language-Specific Assessment Criteria

## Language Classification
- **Tier:** statically-typed
- **Primary safety mechanism:** Compile-time type checking with explicit error handling via return values
- **Key principle:** Go's type system and explicit error returns are the primary safety mechanisms; assess quality of type usage, interface design, and error handling discipline.

## Type Safety
### What to Examine
- Use of `interface{}` / `any` (Go 1.18+) — lower frequency is better
- Custom types for domain concepts (type UserId int64, type Email string)
- Interface compliance and design: small, focused interfaces
- Error handling: custom error types, error wrapping (fmt.Errorf with %w), sentinel errors
- Struct tags for validation

### Evidence Commands
```bash
echo "=== interface{}/any usage ==="
grep -r "interface{}\|any" --include="*.go" . 2>/dev/null | grep -v vendor | grep -v .git | wc -l

echo "=== Custom types ==="
grep -r "^type " --include="*.go" . 2>/dev/null | grep -v vendor | grep -v .git | wc -l

echo "=== Interface definitions ==="
grep -r "type.*interface {" --include="*.go" . 2>/dev/null | grep -v vendor | grep -v .git | wc -l

echo "=== Error wrapping ==="
grep -r "fmt.Errorf.*%w\|errors.Is\|errors.As" --include="*.go" . 2>/dev/null | grep -v vendor | grep -v .git | wc -l

echo "=== Validation libraries ==="
grep -r "validator\|validate" go.mod 2>/dev/null | head -5

echo "=== Struct tags ==="
grep -r "validate:\"" --include="*.go" . 2>/dev/null | grep -v vendor | grep -v .git | wc -l
```

### Scoring Criteria
- **0-20**: Loose typing, widespread interface{}/any, no custom types, bare error returns
- **21-40**: Basic structs but no custom types for domain concepts, minimal error wrapping
- **41-60**: Custom types present, some interface contracts, basic error wrapping
- **61-80**: Well-defined interfaces, custom error types, struct validation tags, consistent error wrapping
- **81-100**: Comprehensive type system usage, validation libraries, minimal interface{}/any, sentinel errors with wrapping

### Language-Specific Notes
- Go's type system is intentionally simple; quality is measured by how well it is leveraged, not by advanced type features.
- `interface{}` / `any` is Go's escape hatch — treat it like `any` in TypeScript.
- Error handling discipline (wrapping, custom types, consistent patterns) is a key Go quality signal.

## Test Foundation
### Tooling & Detection
- **Framework:** go test (built-in, standard)
- **Coverage:** go test -coverprofile (built-in)
- **Mutation testing:** Limited ecosystem; gremlins, go-mutesting
- **Property-based testing:** gopter, rapid
- **File convention:** *_test.go files in the same package

### Evidence Commands
```bash
echo "=== Test file count ==="
find . -name "*_test.go" 2>/dev/null | grep -v vendor | grep -v .git | wc -l

echo "=== Source file count ==="
find . -name "*.go" -not -name "*_test.go" 2>/dev/null | grep -v vendor | grep -v .git | wc -l

echo "=== Coverage in CI ==="
grep -r "coverprofile\|coverage\|go test" .github/ .circleci/ .buildkite/ Makefile 2>/dev/null | head -5

echo "=== Table-driven tests (Go idiom) ==="
grep -r "tests := \[\]struct\|tt := \[\]struct\|testCases" --include="*_test.go" . 2>/dev/null | grep -v vendor | grep -v .git | wc -l

echo "=== Property-based testing ==="
grep -r "gopter\|rapid" go.mod 2>/dev/null | head -3

echo "=== Skipped tests ==="
grep -r "t.Skip\|testing.Short" --include="*_test.go" . 2>/dev/null | grep -v vendor | grep -v .git | wc -l
```

### Scoring Notes
- **Skip patterns:** `t.Skip()`, `testing.Short()`
- **Mock indicators:** Generated mocks (mockgen), testify mocks, interface-based test doubles
- Table-driven tests are idiomatic Go and a positive signal
- Go's built-in test tooling means no framework setup overhead; lack of tests is a stronger negative signal

## Feedback Loops
### Tooling
- **Pre-commit:** lefthook, pre-commit framework
- **Parallel test runner:** go test runs packages in parallel by default; `-parallel` flag for test-level parallelism
- **Security scanners:** gosec, govulncheck

### Evidence Commands
```bash
ls lefthook.yml .pre-commit-config.yaml 2>/dev/null
grep -r "gosec\|govulncheck\|staticcheck" .github/ .circleci/ .buildkite/ Makefile 2>/dev/null | head -5
```

## Code Clarity
### Conventions
- **Extensions:** .go
- **Idiomatic file size:** Shorter files preferred; one type per file is idiomatic Go
- **Naming:** camelCase for unexported, PascalCase for exported; short variable names idiomatic in small scopes
- **File organization:** Package-based; package name matches directory name

## Consistency & Conventions
### Tooling
- **Linter:** golangci-lint (.golangci.yml or .golangci.yaml) — aggregates many linters
- **Formatter:** gofmt (built-in, universally adopted); goimports for import organization
- **Static analysis:** staticcheck, vet (built-in)

### Evidence Commands
```bash
echo "=== golangci-lint config ==="
ls .golangci.yml .golangci.yaml 2>/dev/null

echo "=== CI linting ==="
grep -r "golangci\|golint\|staticcheck\|go vet" .github/ .circleci/ .buildkite/ Makefile 2>/dev/null | head -5

echo "=== Makefile targets ==="
grep -r "lint\|fmt\|vet" Makefile 2>/dev/null | head -5
```

## Architecture
### Framework Conventions
- **Go module layout:** cmd/ (entrypoints), internal/ (private packages), pkg/ (public packages)
- **Dependency injection:** wire, fx, or manual constructor injection
- **API frameworks:** net/http (stdlib), gin, echo, chi

### Evidence Commands
```bash
echo "=== Standard layout ==="
ls cmd/ internal/ pkg/ 2>/dev/null

echo "=== Module structure ==="
find . -name "go.mod" 2>/dev/null | grep -v vendor | grep -v .git | head -5

echo "=== Directory structure ==="
find . -maxdepth 2 -type d 2>/dev/null | grep -v vendor | grep -v .git | head -20

echo "=== DI framework ==="
grep -r "wire\|uber.org/fx\|dig" go.mod 2>/dev/null | head -5
```

### Co-Change Notes
- go.sum churn is expected on dependency updates and should not penalize
- cmd/ + internal/ co-changes for the same feature are expected

## Change Safety
### Tooling
- **Feature flags:** Custom implementations, go-feature-flag, LaunchDarkly Go SDK
- **Database migrations:** golang-migrate, goose, atlas
- **Dependency management:** Go modules (go.mod)

### Evidence Commands
```bash
echo "=== Feature flags ==="
grep -r "feature.flag\|feature_flag\|featureflag\|launchdarkly" --include="*.go" . 2>/dev/null | grep -v vendor | grep -v .git | grep -v _test.go | wc -l

echo "=== Migration tools ==="
grep -r "golang-migrate\|goose\|atlas" go.mod 2>/dev/null | head -5
find . -path "*/migrations/*" -name "*.sql" 2>/dev/null | grep -v vendor | wc -l
```
