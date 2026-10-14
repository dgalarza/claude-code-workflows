# TypeScript — Language-Specific Assessment Criteria

## Language Classification
- **Tier:** statically-typed
- **Primary safety mechanism:** Compile-time type checking via tsc with strict mode configuration
- **Key principle:** TypeScript's value scales directly with strictness configuration; strict mode ON is the baseline expectation for a well-typed codebase.

## Type Safety
### What to Examine
- tsconfig.json strict mode and related flags (noImplicitAny, strictNullChecks, strictFunctionTypes)
- `any` type usage frequency — lower is better; measure as percentage of total type annotations
- Runtime validation libraries: Zod, io-ts, class-validator for boundaries (API inputs, external data)
- CI enforcement of type checking (tsc --noEmit in CI pipeline)

### Evidence Commands
```bash
echo "=== tsconfig strict settings ==="
cat tsconfig.json 2>/dev/null | grep -A5 -i '"strict\|compilerOptions'
grep -r '"strict":\s*true\|"noImplicitAny"' tsconfig*.json 2>/dev/null

echo "=== any usage count ==="
grep -r ": any\|as any\|<any>" --include="*.ts" --include="*.tsx" . 2>/dev/null \
  | grep -v node_modules | grep -v .git | grep -v ".d.ts" | wc -l

echo "=== Total TS files (for any-ratio context) ==="
find . -name "*.ts" -o -name "*.tsx" 2>/dev/null | grep -v node_modules | grep -v .git | wc -l

echo "=== Runtime validation ==="
grep -r "\"zod\"\|\"io-ts\"\|\"class-validator\"\|\"superstruct\"" package.json 2>/dev/null

echo "=== CI type checking ==="
grep -r "tsc\|type-check\|typecheck" .github/ .circleci/ .buildkite/ package.json 2>/dev/null | head -5
```

### Scoring Criteria
- **0-20**: No strict mode, widespread `any`, no runtime validation
- **21-40**: Strict mode off or partially configured, frequent `any` usage
- **41-60**: Strict mode on, but no runtime validation at boundaries
- **61-80**: Strict mode + runtime validation in critical paths (API boundaries, external data), CI enforced
- **81-100**: Strict mode + comprehensive runtime validation + CI enforcement + `any` usage <5% of annotations

### Language-Specific Notes
- `any` is the primary escape hatch in TypeScript; its frequency is a direct measure of type safety holes.
- Runtime validation (Zod, io-ts) at API boundaries is critical because TypeScript types are erased at runtime.
- Check for `@ts-ignore` and `@ts-expect-error` comments as additional escape hatch indicators.

## Test Foundation
### Tooling & Detection
- **Framework:** Jest (jest.config.*), Vitest (vitest.config.*)
- **Coverage:** jest --coverage, coverageThreshold in jest.config; c8/istanbul for Vitest
- **Mutation testing:** Stryker (@stryker-mutator/*)
- **Property-based testing:** fast-check

### Evidence Commands
```bash
echo "=== Test framework ==="
ls jest.config.* vitest.config.* 2>/dev/null
grep -r "\"jest\"\|\"vitest\"" package.json 2>/dev/null | head -5

echo "=== Coverage config ==="
grep -r "coverageThreshold\|collectCoverage" jest.config.* vitest.config.* 2>/dev/null | head -5
grep -r "coverage" .github/ .circleci/ .buildkite/ 2>/dev/null | head -5

echo "=== Mutation testing ==="
grep -r "stryker" package.json 2>/dev/null

echo "=== Property-based testing ==="
grep -r "fast-check" package.json 2>/dev/null

echo "=== Skipped tests ==="
grep -r "\.skip\|xit\|xdescribe\|xtest" --include="*.test.*" --include="*.spec.*" . 2>/dev/null | grep -v node_modules | grep -v .git | wc -l

echo "=== Mock density ==="
grep -r "jest.fn\|jest.mock\|vi.fn\|vi.mock\|sinon" --include="*.test.*" --include="*.spec.*" . 2>/dev/null | grep -v node_modules | grep -v .git | wc -l

echo "=== Test retry ==="
grep -r "jest-circus\|retry\|retries" jest.config.* vitest.config.* 2>/dev/null | head -3
```

### Scoring Notes
- **Skip patterns:** `.skip`, `xit`, `xdescribe`, `xtest`
- **Mock indicators:** `jest.fn`, `jest.mock`, `vi.fn`, `vi.mock`, `sinon`
- **Retry plugins:** jest retry, vitest retry configuration
- TypeScript test files should themselves be well-typed; test files using `any` heavily indicate weak test quality

## Feedback Loops
### Tooling
- **Pre-commit:** Husky (.husky/ directory), lint-staged
- **Parallel test runner:** Jest workers (default), Vitest threads
- **Security scanners:** npm audit, CodeQL, Snyk

### Evidence Commands
```bash
echo "=== Pre-commit ==="
ls .husky/ 2>/dev/null
grep -r "husky\|lint-staged" package.json 2>/dev/null | head -5

echo "=== Security ==="
grep -r "npm audit\|snyk\|codeql" .github/ .circleci/ .buildkite/ 2>/dev/null | head -5
```

## Code Clarity
### Conventions
- **Extensions:** .ts, .tsx (React components)
- **Idiomatic file size:** Varies by framework; components should be focused, utility files modular
- **Naming:** camelCase for files/variables, PascalCase for components/classes/interfaces/types
- **File organization:** Co-location of component + test + styles is common in React codebases

## Consistency & Conventions
### Tooling
- **Linter:** ESLint (.eslintrc.*, eslint.config.*)
- **Formatter:** Prettier (.prettierrc*, .prettierignore)
- **Custom rules:** Custom ESLint rules or plugins for project-specific patterns

### Evidence Commands
```bash
echo "=== ESLint config ==="
ls .eslintrc.* eslint.config.* 2>/dev/null
grep -r "eslint" .github/ .circleci/ .buildkite/ 2>/dev/null | head -5

echo "=== Prettier config ==="
ls .prettierrc* .prettierignore 2>/dev/null

echo "=== Custom ESLint plugins ==="
grep -r "eslint-plugin\|eslint-rule" package.json 2>/dev/null | head -5
find . -name "*.js" -path "*eslint*" -not -path "*/node_modules/*" 2>/dev/null | head -5
```

## Architecture
### Framework Conventions
- **Next.js:** pages/ or app/ directory, API routes, components/
- **Express:** routes/, controllers/, middleware/
- **Monorepo:** packages/, apps/, libs/ (Turborepo, Nx, Lerna)
- **General:** src/ directory as source root

### Evidence Commands
```bash
echo "=== Framework detection ==="
grep -r "\"next\"\|\"express\"\|\"fastify\"\|\"nestjs\"" package.json 2>/dev/null | head -5

echo "=== Monorepo structure ==="
find . -maxdepth 3 -name "package.json" 2>/dev/null | grep -v node_modules | grep -v .git | wc -l
ls packages/ apps/ libs/ modules/ 2>/dev/null

echo "=== Directory structure ==="
find . -maxdepth 2 -type d 2>/dev/null | grep -v node_modules | grep -v .git | head -20

echo "=== Circular dependency indicators ==="
grep -r "import.*from.*\.\.\/" --include="*.ts" --include="*.tsx" . 2>/dev/null | grep -v node_modules | grep -v .git | wc -l
```

### Co-Change Notes
- package-lock.json / yarn.lock churn is expected and should not penalize
- In monorepos, shared package changes triggering consumer updates is expected
- Next.js page + API route co-changes for the same feature are expected

## Change Safety
### Tooling
- **Feature flags:** LaunchDarkly, Unleash, custom feature-flags packages, environment-based flags
- **Database migrations:** Prisma migrations, TypeORM migrations, Knex migrations

### Evidence Commands
```bash
echo "=== Feature flags ==="
grep -r "launchdarkly\|unleash\|feature-flag\|featureFlag" package.json 2>/dev/null | head -5
grep -r "featureFlag\|feature_flag\|isEnabled\|isFeatureEnabled" --include="*.ts" --include="*.tsx" . 2>/dev/null | grep -v node_modules | grep -v .git | grep -v test | wc -l

echo "=== Database migrations ==="
find . -path "*/migrations/*" -name "*.ts" 2>/dev/null | grep -v node_modules | grep -v .git | wc -l
ls prisma/migrations/ 2>/dev/null
```
