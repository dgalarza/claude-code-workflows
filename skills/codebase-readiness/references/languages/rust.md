# Rust — Language-Specific Assessment Criteria

## Language Classification
- **Tier:** statically-typed
- **Primary safety mechanism:** Ownership system + compile-time type checking + `Result<T,E>` error handling
- **Key principle:** Rust's ownership/borrow checker and type system eliminate entire classes of bugs at compile time. Assess quality of type usage, error handling discipline, and minimization of escape hatches (`unsafe`, `unwrap()`).

## Type Safety
### What to Examine
- Use of `unsafe {}` blocks — lower frequency is better; each should have a `// SAFETY:` comment
- `unwrap()` / `expect()` in non-test code — panic-on-failure anti-pattern; `clippy::unwrap_used` / `clippy::expect_used` lints enforce discipline
- `dyn Any` usage — type erasure escape hatch
- `transmute` usage — dangerous type-level escape hatch
- Raw pointer usage (`*const T`, `*mut T`) — another unsafe primitive
- Custom newtypes for domain concepts (`struct UserId(u64)`, `struct Email(String)`)
- Trait bounds and generic constraints — well-bounded generics signal strong type discipline
- `#[must_use]` annotations — strong API discipline signal
- `From`/`Into` trait implementations — idiomatic type conversions
- Error handling: `thiserror`/`snafu` (libraries) vs `anyhow`/`color-eyre` (binaries), custom error enums with `Result<T,E>`
- `Result<T,E>` vs bare panics — explicit error propagation with `?` operator

### Evidence Commands
```bash
echo "=== unsafe usage count ==="
grep -r "unsafe " --include="*.rs" . 2>/dev/null | grep -v target | grep -v .git | wc -l

echo "=== SAFETY comments on unsafe ==="
grep -r "// SAFETY:" --include="*.rs" . 2>/dev/null | grep -v target | grep -v .git | wc -l

echo "=== unwrap()/expect() in non-test code (approx — includes in-file test modules) ==="
grep -rE "\.unwrap\(\)|\.expect\(" --include="*.rs" . 2>/dev/null | grep -v target | grep -v .git | grep -v "/tests/" | wc -l

echo "=== Clippy unwrap lint enabled ==="
grep -rE "deny\(clippy::(unwrap_used|expect_used)" --include="*.rs" --include="Cargo.toml" --include="clippy.toml" --include=".clippy.toml" . 2>/dev/null | grep -v target | head -5

echo "=== transmute usage ==="
grep -r "transmute" --include="*.rs" . 2>/dev/null | grep -v target | grep -v .git | wc -l

echo "=== Raw pointer usage ==="
grep -rE "\*const |\*mut " --include="*.rs" . 2>/dev/null | grep -v target | grep -v .git | wc -l

echo "=== dyn Any usage ==="
grep -r "dyn Any" --include="*.rs" . 2>/dev/null | grep -v target | grep -v .git | wc -l

echo "=== Custom newtypes ==="
grep -rE "^(pub(\([^)]+\))? )?struct [A-Z][a-zA-Z]+\(.+\)" --include="*.rs" . 2>/dev/null | grep -v target | grep -v .git | wc -l

echo "=== Error handling libraries ==="
grep -rE "thiserror|anyhow|color-eyre|snafu" --include="Cargo.toml" . 2>/dev/null | grep -v target | head -5

echo "=== Result usage ==="
grep -r "Result<" --include="*.rs" . 2>/dev/null | grep -v target | grep -v .git | wc -l

echo "=== Trait definitions ==="
grep -rE "^(pub(\([^)]+\))? )?trait " --include="*.rs" . 2>/dev/null | grep -v target | grep -v .git | wc -l

echo "=== #[must_use] annotations ==="
grep -r "#\[must_use\]" --include="*.rs" . 2>/dev/null | grep -v target | grep -v .git | wc -l

echo "=== From/Into implementations ==="
grep -rE "impl .* From<" --include="*.rs" . 2>/dev/null | grep -v target | grep -v .git | wc -l
```

### Scoring Criteria
- **0-20**: Widespread `unsafe`, excessive `unwrap()`, no custom types, bare panics in library code
- **21-40**: Minimal newtypes, frequent `unwrap()` outside tests, unstructured error handling
- **41-60**: Some newtypes, `thiserror`/`anyhow` present, moderate `unwrap()` usage with `expect()` messages
- **61-80**: Well-defined newtypes, structured error enums, `unsafe` blocks documented with `// SAFETY:`, minimal `unwrap()`
- **81-100**: Comprehensive newtype usage, zero undocumented `unsafe`, `unwrap()`-free non-test code, rich trait bounds, `Result<T,E>` throughout

### Language-Specific Notes
- Rust's ownership system prevents data races and memory errors at compile time — the type system does more work than most languages.
- `unsafe {}` is Rust's escape hatch — treat it like `any` in TypeScript or `interface{}` in Go. Every `unsafe` block should have a `// SAFETY:` comment.
- `unwrap()` in non-test code is a panic-on-failure anti-pattern; `expect("reason")` is slightly better but still panics. Prefer `?` propagation. Projects enabling `clippy::unwrap_used` / `clippy::expect_used` lints demonstrate strong discipline.
- `transmute` and raw pointers are deeper escape hatches than `unsafe` blocks alone — their presence warrants close inspection.
- Error handling discipline (`thiserror`/`snafu` for libraries, `anyhow`/`color-eyre` for binaries, `?` operator) is a key Rust quality signal.
- `#[deny(warnings)]` in source code is a known anti-pattern (causes breakage on compiler upgrades) — prefer CI-only `-D warnings` via rustflags.

## Test Foundation
### Tooling & Detection
- **Framework:** cargo test (built-in, standard)
- **Coverage:** cargo-tarpaulin, cargo-llvm-cov
- **Mutation testing:** cargo-mutants
- **Property-based testing:** proptest, quickcheck
- **Snapshot testing:** insta (cargo-insta)
- **Parametric testing:** rstest
- **Benchmarking:** criterion, divan
- **Mocking:** mockall
- **CLI testing:** assert_cmd, assert_fs
- **Parallel runner:** cargo-nextest
- **File convention:** `#[cfg(test)] mod tests` in-file + `tests/*.rs` integration tests + doc tests in `///` and `//!` comments

### Evidence Commands
```bash
echo "=== In-file test modules ==="
grep -r "#\[cfg(test)\]" --include="*.rs" . 2>/dev/null | grep -v target | grep -v .git | wc -l

echo "=== Integration test files ==="
find . -path "*/tests/*.rs" 2>/dev/null | grep -v target | grep -v .git | wc -l

echo "=== Source file count ==="
find . -name "*.rs" 2>/dev/null | grep -v target | grep -v .git | grep -v "/tests/" | wc -l

echo "=== Doc tests ==="
grep -rE "/// ```|//! ```" --include="*.rs" . 2>/dev/null | grep -v target | grep -v .git | wc -l

echo "=== Testing/coverage in CI ==="
grep -rE "tarpaulin|llvm-cov|cargo test|nextest" .github/ .circleci/ .buildkite/ Makefile 2>/dev/null | head -5

echo "=== Snapshot/property/benchmark/mock testing ==="
grep -rE "insta|proptest|quickcheck|criterion|divan|mockall|rstest|assert_cmd|assert_fs|cargo-mutants" --include="Cargo.toml" . 2>/dev/null | grep -v target | head -10

echo "=== Ignored tests ==="
grep -r "#\[ignore\]" --include="*.rs" . 2>/dev/null | grep -v target | grep -v .git | wc -l
```

### Scoring Notes
- **Skip patterns:** `#[ignore]` attribute on test functions
- **Mock indicators:** mockall or trait-based test doubles
- Rust's in-file `#[cfg(test)] mod tests` pattern means test count requires grepping, not just file counting
- Doc tests (`/// ````) are a strong positive signal — they ensure examples stay compilable
- `cargo test` runs unit tests, integration tests, and doc tests by default
- `insta` snapshot testing is widely used in the Rust ecosystem and a strong positive signal
- `cargo-nextest` for parallel test execution is both a feedback loop and test foundation signal

## Feedback Loops
### Tooling
- **Pre-commit:** lefthook, pre-commit framework
- **Linter:** cargo clippy (official lint tool, highly configurable)
- **Formatter:** rustfmt (official, universally adopted)
- **Fast checking:** cargo check (type checking without full compilation)
- **Watch mode:** cargo-watch, bacon (auto-rerun on file change)
- **Parallel test runner:** cargo-nextest (faster parallel test execution)
- **Security scanners:** cargo-audit, cargo-deny

### Evidence Commands
```bash
ls lefthook.yml .pre-commit-config.yaml 2>/dev/null
grep -rE "clippy|cargo-audit|cargo-deny|nextest|cargo check" .github/ .circleci/ .buildkite/ Makefile 2>/dev/null | head -5
```

## Code Clarity
### Conventions
- **Extensions:** .rs
- **Idiomatic file size:** Moderate files; one type per module is idiomatic
- **Naming:** snake_case for functions/modules/variables, PascalCase for types/traits, SCREAMING_SNAKE_CASE for constants
- **File organization:** Module system — `module/mod.rs` (2015 style) or `module.rs` + `module/` subdirectory (2018+ style)

## Consistency & Conventions
### Tooling
- **Linter:** clippy (clippy.toml or .clippy.toml for configuration)
- **Formatter:** rustfmt (rustfmt.toml for configuration)
- **Toolchain pinning:** rust-toolchain.toml
- **Dependency policy:** cargo-deny (deny.toml)
- **Cargo configuration:** .cargo/config.toml
- **Observability:** tracing, log (ecosystem standard crates)

### Evidence Commands
```bash
echo "=== Formatter/linter config ==="
ls rustfmt.toml clippy.toml .clippy.toml .cargo/config.toml rust-toolchain.toml deny.toml 2>/dev/null

echo "=== CI linting ==="
grep -rE "clippy|rustfmt|cargo fmt" .github/ .circleci/ .buildkite/ Makefile 2>/dev/null | head -5

echo "=== Clippy deny warnings ==="
grep -rE "\-D warnings|\-D clippy|deny\(clippy" .cargo/config.toml Makefile .github/ 2>/dev/null | head -5

echo "=== deny(warnings) anti-pattern ==="
grep -r "deny(warnings)" --include="*.rs" . 2>/dev/null | grep -v target | grep -v .git | head -5

echo "=== missing_docs enforcement ==="
grep -rE "warn\(missing_docs\)|deny\(missing_docs\)" --include="*.rs" . 2>/dev/null | grep -v target | head -5

echo "=== Observability ==="
grep -rE "tracing|\"log\"" --include="Cargo.toml" . 2>/dev/null | grep -v target | head -5
```

## Architecture
### Framework Conventions
- **Standard layout:** `src/` (source), `tests/` (integration tests), `benches/` (benchmarks), `examples/` (example programs)
- **Entry points:** `src/main.rs` (binary), `src/lib.rs` (library)
- **Workspace structure:** `[workspace]` in root `Cargo.toml` with member crates; `[workspace.dependencies]` for dependency inheritance (modern practice)
- **Web frameworks:** actix-web, axum (current standard), rocket
- **Async runtimes:** tokio (dominant), async-std
- **Build scripts:** `build.rs` for code generation or native dependencies

### Evidence Commands
```bash
echo "=== Standard layout ==="
ls src/main.rs src/lib.rs tests/ benches/ examples/ 2>/dev/null

echo "=== Workspace structure ==="
grep -A5 "\[workspace\]" Cargo.toml 2>/dev/null | head -10

echo "=== Directory structure ==="
find . -maxdepth 2 -type d 2>/dev/null | grep -v target | grep -v .git | head -20
```

### Co-Change Notes
- Cargo.lock churn is expected on dependency updates and should not penalize
- `src/` + `tests/` co-changes for the same feature are expected
- Workspace member crates may have coordinated version bumps

## Change Safety
### Tooling
- **Feature flags:** Cargo feature flags (`#[cfg(feature = "...")]`), compile-time feature gating
- **Security scanning:** cargo-audit (advisories), cargo-deny (license + advisories + bans)
- **Database migrations:** diesel, sqlx, sea-orm-migration
- **Dependency management:** Cargo.lock (committed for binaries; optional for libraries)
- **Toolchain pinning:** rust-toolchain.toml (specific version like `1.75.0` is a stronger signal than just `stable`)
- **MSRV policy:** `rust-version` field in Cargo.toml indicates backward compatibility maintenance

### Evidence Commands
```bash
echo "=== Feature flags ==="
grep -r "cfg(feature" --include="*.rs" . 2>/dev/null | grep -v target | grep -v .git | wc -l

echo "=== Security scanning ==="
grep -rE "cargo-audit|cargo-deny" .github/ .circleci/ .buildkite/ Makefile 2>/dev/null | head -5

echo "=== Migration tools ==="
grep -rE "diesel|sqlx|sea-orm" --include="Cargo.toml" . 2>/dev/null | grep -v target | head -5
find . -path "*/migrations/*" -name "*.sql" 2>/dev/null | grep -v target | wc -l

echo "=== Reproducibility ==="
[ -f "Cargo.lock" ] && echo "Cargo.lock present" || echo "Cargo.lock absent"
cat rust-toolchain.toml 2>/dev/null || echo "No rust-toolchain.toml"
grep -r "rust-version" --include="Cargo.toml" . 2>/dev/null | grep -v target | head -3
grep -r 'edition = ' --include="Cargo.toml" . 2>/dev/null | grep -v target | head -3
```
