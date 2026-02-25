# Scala — Language-Specific Assessment Criteria

## Language Classification
- **Tier:** statically-typed
- **Primary safety mechanism:** Compile-time type checking with rich type system (sealed traits, case classes, path-dependent types, implicits) and functional programming patterns (Option, Either, IO monads)
- **Key principle:** Scala's type system is one of the most expressive in mainstream languages. Assess how well the codebase leverages it — sealed ADTs, Option over null, explicit error types, and domain modeling through types rather than runtime checks.

## Type Safety
### What to Examine
- Sealed traits and case classes for algebraic data types (ADTs)
- Option usage vs null — Scala strongly prefers Option; null presence is a code smell
- Either/Try for explicit error handling vs thrown exceptions
- Effect types (cats IO, ZIO, custom monads like EitherT) for typed error channels
- asInstanceOf as the primary escape hatch — lower frequency is better
- Any/AnyRef usage — Scala's equivalent of Java's Object
- Value classes (extends AnyVal) or opaque types for domain newtypes (e.g., UserId wrapping Long)
- Enumeratum or sealed trait enums vs Scala Enumeration (which loses exhaustivity checking)
- Protobuf/generated types for domain models at service boundaries
- Database constraints in schema migrations

### Evidence Commands
```bash
echo "=== Sealed traits/classes (ADTs) ==="
grep -r "sealed trait\|sealed abstract\|sealed class" --include="*.scala" . 2>/dev/null \
  | grep -v .git | grep -v target | grep -v test | wc -l

echo "=== Case classes ==="
grep -r "case class" --include="*.scala" . 2>/dev/null \
  | grep -v .git | grep -v target | grep -v test | wc -l

echo "=== Option usage ==="
grep -r "Option\[" --include="*.scala" . 2>/dev/null \
  | grep -v .git | grep -v target | grep -v test | wc -l

echo "=== Null usage (bad signal) ==="
grep -r "= null\b\|== null\b\|!= null\b\|eq null\b\|ne null\b" --include="*.scala" . 2>/dev/null \
  | grep -v .git | grep -v target | grep -v test | wc -l

echo "=== asInstanceOf (primary escape hatch) ==="
grep -r "asInstanceOf\[" --include="*.scala" . 2>/dev/null \
  | grep -v .git | grep -v target | grep -v test | wc -l

echo "=== Any/AnyRef usage ==="
grep -r ": Any\b\|: AnyRef\b\|\[Any\]\|\[AnyRef\]" --include="*.scala" . 2>/dev/null \
  | grep -v .git | grep -v target | grep -v test | wc -l

echo "=== Either usage (explicit error handling) ==="
grep -r "Either\[" --include="*.scala" . 2>/dev/null \
  | grep -v .git | grep -v target | grep -v test | wc -l

echo "=== Effect types (cats/ZIO) ==="
grep -rl "import cats\.\|import zio\.\|EitherT\[" --include="*.scala" . 2>/dev/null \
  | grep -v .git | grep -v target | grep -v test | wc -l

echo "=== Value classes / newtypes ==="
grep -r "extends AnyVal\|opaque type" --include="*.scala" . 2>/dev/null \
  | grep -v .git | grep -v target | grep -v test | wc -l

echo "=== Enumeratum (type-safe enums) ==="
grep -r "extends EnumEntry\|extends Enum\[" --include="*.scala" . 2>/dev/null \
  | grep -v .git | grep -v target | grep -v test | wc -l

echo "=== Scala Enumeration (weaker, no exhaustivity) ==="
grep -r "extends Enumeration" --include="*.scala" . 2>/dev/null \
  | grep -v .git | grep -v target | grep -v test | wc -l

echo "=== Protobuf-generated types ==="
find . -name "*.proto" -not -path "*/target/*" 2>/dev/null | wc -l

echo "=== Database constraints ==="
grep -r "CHECK\|CONSTRAINT\|NOT NULL\|REFERENCES\|FOREIGN KEY\|UNIQUE" --include="*.sql" . 2>/dev/null \
  | grep -v .git | grep -v target | wc -l
```

### Scoring Criteria
- **0-20**: Pervasive null usage, widespread asInstanceOf/Any, no sealed traits, no domain modeling through types
- **21-40**: Basic case classes but heavy null/Any usage, minimal sealed traits, thrown exceptions as primary error handling
- **41-60**: Option preferred over null, some sealed traits, Either present but inconsistent, some asInstanceOf casts remain
- **61-80**: Option pervasive (null near-zero), sealed traits for ADTs, Either/effect types for error handling, few asInstanceOf casts, Enumeratum or sealed enums
- **81-100**: Comprehensive type-driven design — sealed ADTs, value classes/newtypes for domain IDs, effect system (cats/ZIO) for typed errors, minimal escape hatches, protobuf-generated boundary types

### Language-Specific Notes
- Scala's primary escape hatches are `asInstanceOf` and `Any` — treat them like `any` in TypeScript.
- Null is technically legal but culturally unacceptable in idiomatic Scala. A high Option-to-null ratio is a strong positive signal.
- Scala `Enumeration` loses pattern match exhaustivity — Enumeratum or sealed traits are preferred. Do not penalize codebases migrating from Enumeration if sealed traits/Enumeratum are also present.
- Effect types (cats IO, ZIO, custom `EitherT[Future, E, A]` monads) provide typed error channels that are invisible to grep-based analysis. Check for `import cats.` or `import zio.` to detect adoption, and count files using the project's effect type (often named `AppIO`, `AugustIO`, etc.).
- Protobuf-generated case classes provide compile-time safety at service boundaries — count `.proto` files as a type safety signal.

## Test Foundation
### Tooling & Detection
- **Framework:** ScalaTest (most common), Specs2, MUnit, uTest
- **Coverage:** scoverage (sbt-scoverage plugin)
- **Mutation testing:** Stryker4s
- **Property-based testing:** ScalaCheck (often via scalatestplus-scalacheck), Hedgehog
- **File convention:** *Spec.scala, *Test.scala, *Suite.scala in test/ or src/test/scala/

### Evidence Commands
```bash
echo "=== Test file count ==="
find . -name "*Spec.scala" -o -name "*Test.scala" -o -name "*Suite.scala" 2>/dev/null \
  | grep -v .git | grep -v target | wc -l

echo "=== Source file count ==="
find . -name "*.scala" -not -path "*/test/*" -not -path "*/it/*" -not -path "*/integration/*" 2>/dev/null \
  | grep -v .git | grep -v target | grep -v node_modules | wc -l

echo "=== Test framework detection ==="
grep -r "scalatest\|specs2\|munit\|utest\|scalatestplus" build.sbt project/*.sbt project/*.scala 2>/dev/null | head -10

echo "=== Coverage tool (scoverage) ==="
grep -r "scoverage\|sbt-scoverage" build.sbt project/*.sbt project/plugins.sbt 2>/dev/null | head -5

echo "=== Mutation testing (Stryker4s) ==="
grep -r "stryker\|sbt-stryker" build.sbt project/*.sbt project/plugins.sbt 2>/dev/null | head -5

echo "=== Property-based testing (ScalaCheck) ==="
grep -r "scalacheck\|scalatestplus.*scalacheck\|hedgehog" build.sbt project/*.sbt 2>/dev/null | head -5

echo "=== ScalaCheck active usage (files using forAll) ==="
find . -name "*.scala" -path "*/test/*" -not -path "*/target/*" -exec grep -l "forAll" {} \; 2>/dev/null | wc -l

echo "=== Skipped/pending tests ==="
find . -name "*Spec.scala" -o -name "*Test.scala" 2>/dev/null \
  | grep -v target | xargs grep -c "pending$\|pending " 2>/dev/null \
  | awk -F: '$2 > 0 {sum += $2} END {print sum+0 " pending tests across files"}'
grep -rn "ignore(" --include="*Spec.scala" --include="*Test.scala" . 2>/dev/null \
  | grep -v target | grep -v "import " | wc -l

echo "=== Mock infrastructure (mock files, not usage) ==="
find . -name "*Mock*.scala" -o -name "*Stub*.scala" -o -name "*Fake*.scala" 2>/dev/null \
  | grep -v target | grep -v .git | wc -l

echo "=== Mock library usage (Mockito) ==="
grep -rl "import org.mockito\|import org.scalatestplus.mockito\|MockitoSugar" --include="*.scala" . 2>/dev/null \
  | grep -v target | grep -v .git | wc -l

echo "=== Integration test presence ==="
find . -type d \( -name "integration" -o -name "it" \) -not -path "*/target/*" 2>/dev/null | head -5
find . -name "*.scala" -path "*/integration/*" -o -name "*.scala" -path "*/it/*" 2>/dev/null \
  | grep -v target | wc -l

echo "=== CI coverage enforcement ==="
grep -r "scoverage\|coverage" .github/ .circleci/ .buildkite/ 2>/dev/null | head -5

echo "=== Test retry/flaky tolerance ==="
grep -r "retryable\|eventually\|retry\|flaky" build.sbt project/*.sbt 2>/dev/null | head -5
```

### Scoring Notes
- **Skip patterns:** `pending` (ScalaTest — a bare word at end of test body), `ignore("test name")` (ScalaTest method). Do NOT count `ignore` appearing in string literals, imports, or comments.
- **Mock indicators:** Count mock *files* (Mock*.scala, Stub*.scala, Fake*.scala) and files importing Mockito as separate signals. Do NOT count `when(` or `mock(` via grep — these produce massive false positives in Scala due to pattern matching syntax and common method names.
- **Property-based testing:** ScalaCheck's `forAll` is the key indicator. Count files containing `forAll` in test directories, not raw grep hits across the codebase.
- ScalaTest's `eventually` is used for async assertions and can indicate either proper async testing or flaky test tolerance — check context before penalizing.
- Integration tests in Scala projects often live in a separate `integration/` or `it/` source root with their own sbt configuration (IntegrationTest scope). These test against real databases and external services, providing high oracle quality.

## Feedback Loops
### Tooling
- **Pre-commit:** Limited pre-commit culture in Scala; scalafmt can check on build via `scalafmtCheckAll`
- **Parallel test runner:** sbt parallel execution (default), forked JVMs for isolation
- **Security scanners:** OWASP Dependency Check (sbt plugin), Snyk, Trivy
- **Dependency management:** Scala Steward, Renovate, Dependabot

### Evidence Commands
```bash
echo "=== Scalafmt in CI ==="
grep -r "scalafmt\|scalafmtCheck" .github/ .circleci/ .buildkite/ 2>/dev/null | head -5

echo "=== Scalafix in CI ==="
grep -r "scalafix" .github/ .circleci/ .buildkite/ 2>/dev/null | head -5

echo "=== Fatal warnings ==="
grep -r "Xfatal-warnings\|fatalWarnings" build.sbt .github/ 2>/dev/null | head -5

echo "=== Security scanning ==="
grep -r "owasp\|dependency-check\|snyk\|trivy" build.sbt .github/ .circleci/ .buildkite/ 2>/dev/null | head -5

echo "=== Dependency management ==="
grep -r "scala-steward\|renovate\|dependabot" .github/ 2>/dev/null | head -5

echo "=== Parallel/forked test execution ==="
grep -r "fork\|parallelExecution\|Test / fork\|IntegrationTest / fork" build.sbt 2>/dev/null | head -5

echo "=== Preflight scripts ==="
find . -name "preflight" -o -name "pre-flight" -o -name "check" 2>/dev/null \
  | grep -v target | grep -v .git | grep -v node_modules | head -5
```

## Code Clarity
### Conventions
- **Extensions:** .scala, .sc (Ammonite scripts)
- **Idiomatic file size:** One class/trait/object per file is conventional, though companion objects colocate with their class. Scala files tend to be concise due to type inference and expression-oriented syntax.
- **Naming:** PascalCase for classes/traits/objects, camelCase for methods/values/variables, UPPER_SNAKE_CASE for constants
- **File organization:** Package hierarchy mirrors directory structure. `src/main/scala/` and `src/test/scala/` is the standard Maven/sbt layout. Play Framework uses `app/` instead of `src/main/scala/`.
- **Auto-generated files:** Slick's `Tables.scala`, protobuf-generated sources in `target/` — exclude these from file size analysis.

## Consistency & Conventions
### Tooling
- **Formatter:** scalafmt (.scalafmt.conf) — the standard Scala formatter
- **Linter:** Scalafix (.scalafix.conf) — semantic linting with custom rule support
- **Compiler warnings:** `-Xfatal-warnings` treats warnings as errors, acting as an additional linting layer
- **Custom rules:** Scalafix supports project-specific custom rules — these are a strong positive signal for agent readiness because violations produce error messages that teach the agent the correct pattern

### Evidence Commands
```bash
echo "=== Scalafmt config ==="
find . -name ".scalafmt.conf" -not -path "*/target/*" 2>/dev/null | head -3
cat .scalafmt.conf 2>/dev/null | head -20

echo "=== Scalafix config ==="
find . -name ".scalafix.conf" -not -path "*/target/*" 2>/dev/null | head -3
cat .scalafix.conf 2>/dev/null

echo "=== Custom Scalafix rules ==="
find . -name "*.scala" -path "*/scalafix/rules/*" -not -path "*/target/*" 2>/dev/null
find . -name "*.scala" -path "*/scalafix/*" -not -path "*/target/*" 2>/dev/null | head -10

echo "=== CI formatting enforcement ==="
grep -r "scalafmt\|scalafix\|Xfatal-warnings" .github/ .circleci/ .buildkite/ 2>/dev/null | head -10

echo "=== Compiler plugins ==="
grep -r "addCompilerPlugin\|compilerPlugin\|semanticdb" build.sbt project/*.sbt 2>/dev/null | head -5

echo "=== sbt plugins ==="
cat project/plugins.sbt 2>/dev/null | grep -v "^$\|^//" | head -20
```

## Architecture
### Framework Conventions
- **Play Framework:** `app/controllers/`, `app/services/`, `app/models/`, `conf/routes` — MVC-ish with service layer
- **Akka/Pekko:** Actor-based with typed actors, cluster sharding, event sourcing patterns
- **http4s/tapir:** Functional HTTP with typed endpoints, middleware composition
- **sbt multi-module:** `build.sbt` with `project(...)` definitions and `dependsOn` — compile-time boundary enforcement between modules
- **Standard layout:** `src/main/scala/`, `src/test/scala/`, `src/it/scala/` (integration tests)

### Evidence Commands
```bash
echo "=== Play Framework structure ==="
ls app/controllers/ app/services/ app/models/ app/repositories/ conf/routes 2>/dev/null | head -5

echo "=== sbt sub-projects ==="
grep -r "lazy val\|\.dependsOn\|project(" build.sbt 2>/dev/null | head -15

echo "=== Module directories ==="
find . -maxdepth 2 -name "build.sbt" -not -path "*/target/*" 2>/dev/null

echo "=== Directory structure ==="
find . -maxdepth 3 -type d -not -path "*/target/*" -not -path "*/.git/*" -not -path "*/node_modules/*" 2>/dev/null | sort | head -40

echo "=== Domain subdirectories in services ==="
find . -path "*/services/*" -type d -not -path "*/target/*" 2>/dev/null | head -20

echo "=== Domain subdirectories in controllers ==="
find . -path "*/controllers/*" -type d -not -path "*/target/*" 2>/dev/null | head -20
```

### Co-Change Notes
- **Expected Scala co-changes (NOT bad coupling):**
  - Controller + service + repository for the same feature
  - Model + database evolution/migration
  - Protobuf definition + generated code
  - Routes file changes alongside controller additions
  - `build.sbt` churn on dependency updates
- **High churn files to exclude from coupling analysis:**
  - `Tables.scala` (auto-generated Slick schema) — changes with every evolution
  - `build.sbt` — changes with every dependency update
  - `AppSpec.scala` or test registry files — changes when any new test is added
  - `conf/routes` — changes with every new endpoint
- These expected co-changes should NOT penalize the architecture score.

## Change Safety
### Tooling
- **Feature flags:** LaunchDarkly Scala SDK, custom FeatureFlag objects, Unleash
- **Database migrations:** Play evolutions (conf/evolutions/), Flyway, Liquibase
- **Dependency management:** sbt with Scala Steward or Renovate

### Evidence Commands
```bash
echo "=== Feature flags ==="
grep -r "featureFlag\|FeatureFlag\|feature_flag\|isEnabled\|isActive" --include="*.scala" . 2>/dev/null \
  | grep -v .git | grep -v target | grep -v test | grep -v spec | wc -l
find . -name "FeatureFlag*" -o -name "*FeatureToggle*" 2>/dev/null \
  | grep -v target | grep -v .git | head -5

echo "=== Database evolutions/migrations ==="
find . -path "*/evolutions/*" -name "*.sql" -not -path "*/target/*" 2>/dev/null | wc -l
find . -path "*/migrations/*" -name "*.sql" -not -path "*/target/*" 2>/dev/null | wc -l

echo "=== Evolution rollback sections ==="
grep -rl "!Downs" --include="*.sql" . 2>/dev/null | grep -v target | wc -l

echo "=== Irreversible operations ==="
grep -r "DROP TABLE\|DROP COLUMN\|ALTER.*DROP" --include="*.sql" . 2>/dev/null \
  | grep -v target | head -10

echo "=== sbt sub-projects (module boundaries) ==="
grep -r "dependsOn\|project(" build.sbt 2>/dev/null | head -10
```
