# JavaScript — Language-Specific Assessment Criteria

## Language Classification
- **Tier:** dynamically-typed
- **Primary safety mechanism:** Runtime validation libraries (Zod, Joi, yup) and JSDoc annotations for editor-level type checking
- **Key principle:** Plain JavaScript projects lack compile-time type safety; assess runtime validation coverage and recommend TypeScript migration as a high-value investment for any plain JS project.

> **Standing recommendation:** For ANY plain JavaScript project, recommend TypeScript migration in High-Value Investments. The @ts-check JSDoc approach is a zero-migration-cost first step.

## Type Safety
### What to Examine
- JSDoc annotations as partial type safety signal (`@param`, `@returns`, `@type`)
- Runtime validation libraries: Zod, Joi, yup at API boundaries and data ingestion points
- TypeScript migration status: presence of any .ts files, allowJs in tsconfig, @ts-check comments
- PropTypes usage in React projects (legacy but still a signal)

### Evidence Commands
```bash
echo "=== Project type ==="
ls tsconfig.json 2>/dev/null && echo "TypeScript project (or mixed)" || echo "JavaScript project (no tsconfig.json)"

echo "=== File counts ==="
find . -name "*.ts" -o -name "*.tsx" 2>/dev/null | grep -v node_modules | grep -v .git | wc -l
find . -name "*.js" -o -name "*.jsx" 2>/dev/null | grep -v node_modules | grep -v .git | wc -l

echo "=== Runtime validation ==="
grep -r "\"zod\"\|\"joi\"\|\"yup\"\|\"ajv\"" package.json 2>/dev/null

echo "=== JSDoc usage ==="
grep -r "@param\|@returns\|@type\|@typedef" --include="*.js" --include="*.jsx" . 2>/dev/null | grep -v node_modules | grep -v .git | wc -l

echo "=== @ts-check usage ==="
grep -r "@ts-check" --include="*.js" --include="*.jsx" . 2>/dev/null | grep -v node_modules | grep -v .git | wc -l

echo "=== PropTypes (React) ==="
grep -r "PropTypes\|prop-types" --include="*.js" --include="*.jsx" . 2>/dev/null | grep -v node_modules | grep -v .git | wc -l
```

### Scoring Criteria
- **0-20**: Plain JS, no JSDoc annotations, no runtime validation
- **21-40**: Plain JS with some JSDoc, no runtime validation
- **41-60**: Runtime validation library (Zod/Joi/yup) in use, JSDoc on critical interfaces
- **61-80**: Comprehensive runtime validation, JSDoc annotations, TypeScript migration started (some .ts files or allowJs in tsconfig)
- **81-100**: TypeScript migration complete or substantially underway with strict mode

### Language-Specific Notes
- Any plain JavaScript project should receive a TypeScript migration recommendation regardless of score.
- `@ts-check` at the top of JS files enables TypeScript checking with zero migration cost — recommend this as a first step.
- JSDoc + `@ts-check` can provide near-TypeScript safety without renaming files.

## Test Foundation
### Tooling & Detection
- **Framework:** Jest (jest.config.*), Vitest (vitest.config.*), Mocha (.mocharc.*)
- **Coverage:** jest --coverage, c8, istanbul/nyc
- **Mutation testing:** Stryker (@stryker-mutator/*)
- **Property-based testing:** fast-check

### Evidence Commands
```bash
echo "=== Test framework ==="
ls jest.config.* vitest.config.* .mocharc.* 2>/dev/null
grep -r "\"jest\"\|\"vitest\"\|\"mocha\"" package.json 2>/dev/null | head -5

echo "=== Coverage config ==="
grep -r "coverageThreshold\|collectCoverage" jest.config.* vitest.config.* 2>/dev/null | head -5
grep -r "nyc\|istanbul\|c8" package.json 2>/dev/null | head -5

echo "=== Mutation testing ==="
grep -r "stryker" package.json 2>/dev/null

echo "=== Property-based testing ==="
grep -r "fast-check" package.json 2>/dev/null

echo "=== Skipped tests ==="
grep -r "\.skip\|xit\|xdescribe\|xtest" --include="*.test.*" --include="*.spec.*" . 2>/dev/null | grep -v node_modules | grep -v .git | wc -l

echo "=== Mock density ==="
grep -r "jest.fn\|jest.mock\|vi.fn\|vi.mock\|sinon" --include="*.test.*" --include="*.spec.*" . 2>/dev/null | grep -v node_modules | grep -v .git | wc -l
```

### Scoring Notes
- **Skip patterns:** `.skip`, `xit`, `xdescribe`, `xtest`
- **Mock indicators:** `jest.fn`, `jest.mock`, `vi.fn`, `vi.mock`, `sinon`
- Without static types, test coverage becomes even more critical in JS projects — weight test foundation higher.

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
- **Extensions:** .js, .jsx (React components)
- **Idiomatic file size:** Similar to TypeScript; components should be focused
- **Naming:** camelCase for files/variables, PascalCase for components/classes
- **File organization:** Co-location patterns common in React; module-based organization in Node.js

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
grep -r "\"next\"\|\"express\"\|\"fastify\"\|\"koa\"" package.json 2>/dev/null | head -5

echo "=== Monorepo structure ==="
find . -maxdepth 3 -name "package.json" 2>/dev/null | grep -v node_modules | grep -v .git | wc -l
ls packages/ apps/ libs/ modules/ 2>/dev/null

echo "=== Directory structure ==="
find . -maxdepth 2 -type d 2>/dev/null | grep -v node_modules | grep -v .git | head -20
```

### Co-Change Notes
- package-lock.json / yarn.lock churn is expected and should not penalize
- In monorepos, shared package changes triggering consumer updates is expected

## Change Safety
### Tooling
- **Feature flags:** LaunchDarkly, Unleash, custom feature-flags packages, environment-based flags
- **Database migrations:** Knex migrations, Sequelize migrations, Prisma migrations

### Evidence Commands
```bash
echo "=== Feature flags ==="
grep -r "launchdarkly\|unleash\|feature-flag\|featureFlag" package.json 2>/dev/null | head -5
grep -r "featureFlag\|feature_flag\|isEnabled\|isFeatureEnabled" --include="*.js" --include="*.jsx" . 2>/dev/null | grep -v node_modules | grep -v .git | grep -v test | wc -l

echo "=== Database migrations ==="
find . -path "*/migrations/*" -name "*.js" 2>/dev/null | grep -v node_modules | grep -v .git | wc -l
```
