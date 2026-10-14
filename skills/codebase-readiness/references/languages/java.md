# Java — Language-Specific Assessment Criteria

## Language Classification
- **Tier:** statically-typed
- **Primary safety mechanism:** Compile-time type checking with strong generics, annotation-based validation, and null safety annotations
- **Key principle:** Java's type system is robust by default; assess quality of generics usage, validation framework adoption, and null safety discipline.

## Type Safety
### What to Examine
- Generics usage quality: raw types vs parameterized types
- Annotation-based validation: Bean Validation (javax.validation / jakarta.validation), Hibernate Validator
- Null safety: Optional usage for nullable returns, @Nullable/@NonNull annotations
- Raw Object casts as escape hatch — lower frequency is better
- Record types (Java 14+) and sealed classes (Java 17+) for domain modeling

### Evidence Commands
```bash
echo "=== Validation framework ==="
grep -r "javax.validation\|jakarta.validation\|hibernate-validator" pom.xml build.gradle 2>/dev/null | head -5

echo "=== Optional usage ==="
grep -r "Optional<" --include="*.java" . 2>/dev/null | grep -v .git | grep -v target | grep -v build | wc -l

echo "=== Null safety annotations ==="
grep -r "@Nullable\|@NonNull\|@NotNull\|@Nonnull" --include="*.java" . 2>/dev/null | grep -v .git | grep -v target | wc -l

echo "=== Raw type usage (bad signal) ==="
grep -r "List \|Map \|Set \|Collection " --include="*.java" . 2>/dev/null | grep -v .git | grep -v target | grep -v "import " | wc -l

echo "=== Record types (modern Java) ==="
grep -r "public record\|record " --include="*.java" . 2>/dev/null | grep -v .git | grep -v target | wc -l

echo "=== Validation annotations ==="
grep -r "@Valid\|@NotNull\|@NotBlank\|@Size\|@Pattern\|@Min\|@Max" --include="*.java" . 2>/dev/null | grep -v .git | grep -v target | wc -l
```

### Scoring Criteria
- **0-20**: Raw types, no generics, widespread Object casts, no validation framework
- **21-40**: Basic generics but no validation annotations, raw types still present
- **41-60**: Generics + some validation annotations, Optional partially adopted
- **61-80**: Comprehensive generics, Bean Validation across domain, Optional for nullable returns
- **81-100**: Full type safety, validation framework, null safety annotations throughout, minimal raw types, modern Java features (records, sealed classes)

### Language-Specific Notes
- Java's type system is strong out of the box; the key differentiator is how well it is leveraged.
- Raw types (List instead of List<String>) are the primary escape hatch — treat like `any` in TypeScript.
- Optional should be used for return types, not parameters (this is the Java convention).

## Test Foundation
### Tooling & Detection
- **Framework:** JUnit 5 (preferred), JUnit 4, TestNG
- **Coverage:** JaCoCo
- **Mutation testing:** PIT (pitest) — well-established in Java ecosystem
- **Property-based testing:** jqwik, junit-quickcheck
- **File convention:** *Test.java, *Spec.java in src/test/

### Evidence Commands
```bash
echo "=== Test file count ==="
find . -name "*Test.java" -o -name "*Spec.java" 2>/dev/null | grep -v .git | grep -v target | grep -v build | wc -l

echo "=== Source file count ==="
find . -name "*.java" -not -name "*Test.java" -not -name "*Spec.java" 2>/dev/null | grep -v .git | grep -v target | grep -v build | wc -l

echo "=== JaCoCo coverage ==="
grep -r "jacoco\|JaCoCo" pom.xml build.gradle 2>/dev/null | head -5

echo "=== Mutation testing (PIT) ==="
grep -r "pitest\|PIT\|pit-maven" pom.xml build.gradle 2>/dev/null | head -5

echo "=== Property-based testing ==="
grep -r "jqwik\|junit-quickcheck" pom.xml build.gradle 2>/dev/null | head -5

echo "=== Skipped tests ==="
grep -r "@Disabled\|@Ignore" --include="*.java" . 2>/dev/null | grep -v .git | grep -v target | wc -l

echo "=== Mock density ==="
grep -r "@Mock\|Mockito\|mock(\|when(\|verify(" --include="*.java" . 2>/dev/null | grep -v .git | grep -v target | wc -l

echo "=== CI coverage ==="
grep -r "jacoco\|coverage\|surefire\|failsafe" .github/ .circleci/ .buildkite/ 2>/dev/null | head -5
```

### Scoring Notes
- **Skip patterns:** `@Disabled` (JUnit 5), `@Ignore` (JUnit 4)
- **Mock indicators:** `@Mock`, `Mockito`, `mock()`, `when()`, `verify()`
- PIT mutation testing is well-supported in Java and its presence is a strong positive signal
- JUnit 5 adoption over JUnit 4 indicates a modern, maintained test suite

## Feedback Loops
### Tooling
- **Pre-commit:** Limited pre-commit culture in Java; Spotless plugin for formatting on build
- **Parallel test runner:** Maven Surefire parallel mode, Gradle parallel test execution
- **Security scanners:** SpotBugs (security rules), OWASP Dependency Check, Snyk

### Evidence Commands
```bash
echo "=== Spotless (format enforcement) ==="
grep -r "spotless" pom.xml build.gradle 2>/dev/null | head -5

echo "=== Security scanning ==="
grep -r "spotbugs\|owasp\|dependency-check\|snyk" pom.xml build.gradle .github/ .circleci/ .buildkite/ 2>/dev/null | head -5

echo "=== Parallel test execution ==="
grep -r "parallel\|forkCount\|useUnlimitedThreads" pom.xml build.gradle 2>/dev/null | head -5
```

## Code Clarity
### Conventions
- **Extensions:** .java
- **Idiomatic file size:** One public class per file (enforced by the language)
- **Naming:** PascalCase for classes, camelCase for methods/variables, UPPER_SNAKE_CASE for constants
- **File organization:** Package hierarchy mirrors directory structure; src/main/java and src/test/java split

## Consistency & Conventions
### Tooling
- **Linter:** Checkstyle, SpotBugs, PMD
- **Formatter:** google-java-format, Eclipse formatter, Spotless plugin
- **Build tool:** Maven (pom.xml), Gradle (build.gradle / build.gradle.kts)

### Evidence Commands
```bash
echo "=== Linter config ==="
grep -r "checkstyle\|spotbugs\|pmd" pom.xml build.gradle 2>/dev/null | head -5
ls checkstyle.xml 2>/dev/null

echo "=== Formatter ==="
grep -r "google-java-format\|spotless\|formatter" pom.xml build.gradle 2>/dev/null | head -5

echo "=== CI linting ==="
grep -r "checkstyle\|spotbugs\|pmd\|lint" .github/ .circleci/ .buildkite/ 2>/dev/null | head -5

echo "=== Build tool ==="
ls pom.xml build.gradle build.gradle.kts 2>/dev/null
```

## Architecture
### Framework Conventions
- **Spring Boot:** src/main/java with controller/service/repository layering
- **Maven modules:** Multi-module project for domain boundaries (pom.xml in subdirectories)
- **Gradle multi-project:** settings.gradle with include statements for subprojects
- **General:** src/main/java, src/main/resources, src/test/java layout

### Evidence Commands
```bash
echo "=== Spring structure ==="
find . -name "*Controller.java" -o -name "*Service.java" -o -name "*Repository.java" 2>/dev/null | grep -v .git | grep -v target | head -10

echo "=== Maven modules ==="
find . -name "pom.xml" -not -path "*/target/*" 2>/dev/null | head -10

echo "=== Gradle subprojects ==="
grep -r "include " settings.gradle settings.gradle.kts 2>/dev/null | head -10

echo "=== Directory structure ==="
find . -maxdepth 3 -type d -path "*/src/main/java/*" 2>/dev/null | head -15
```

### Co-Change Notes
- Spring controller + service + repository co-changes for the same feature are expected
- Maven/Gradle build file churn on dependency updates is expected
- application.properties / application.yml frequent changes are expected in active projects

## Change Safety
### Tooling
- **Feature flags:** Togglz, FF4J, LaunchDarkly Java SDK, Unleash
- **Database migrations:** Flyway, Liquibase
- **Dependency management:** Maven (pom.xml), Gradle (build.gradle)

### Evidence Commands
```bash
echo "=== Feature flags ==="
grep -r "togglz\|ff4j\|launchdarkly\|unleash\|feature.flag" pom.xml build.gradle 2>/dev/null | head -5
grep -r "isActive\|isEnabled\|featureFlag\|FeatureToggle" --include="*.java" . 2>/dev/null | grep -v .git | grep -v target | grep -v test | wc -l

echo "=== Database migrations ==="
grep -r "flyway\|liquibase" pom.xml build.gradle 2>/dev/null | head -5
find . -path "*/db/migration/*" -o -path "*/changelog/*" 2>/dev/null | grep -v .git | grep -v target | wc -l
```
