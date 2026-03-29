# Monorepo Documentation Audit Patterns

Additional audit considerations for monorepo projects (Turborepo, Nx, Lerna, pnpm workspaces, Yarn workspaces, Cargo workspaces).

## Detection

A project is a monorepo if any of these exist:
- `turbo.json` (Turborepo)
- `nx.json` (Nx)
- `lerna.json` (Lerna)
- `pnpm-workspace.yaml` (pnpm workspaces)
- `package.json` with `"workspaces"` field (Yarn/npm workspaces)
- `Cargo.toml` with `[workspace]` section (Cargo)

## Completeness Checks

- [ ] **Root ARCHITECTURE.md codemap** lists every package/workspace
- [ ] **Each package** is described with its purpose and public API surface
- [ ] **Shared packages** document their exports -- what do other packages import from them?
- [ ] **Package dependency graph** is documented or at least implied by the codemap
- [ ] **Root AGENTS.md** explains the monorepo structure and how to navigate it

## Accuracy Checks

- [ ] **Package names** in docs match actual `package.json` names or directory names
- [ ] **Build/test commands** cover all packages (e.g., `pnpm -r test` not just `pnpm test`)
- [ ] **Inter-package dependencies** documented match actual imports
- [ ] **Service ports** for each package match docker-compose and .env
- [ ] **Infrastructure table** (if present) lists all services with correct ports

## Freshness Checks

- [ ] **New packages** added since docs were last updated are documented
- [ ] **Removed packages** no longer referenced in docs
- [ ] **Package-level changes** reflected in root docs when they affect the overall architecture

## Coherence Checks

- [ ] **No conflicting build instructions** between root README and package READMEs
- [ ] **Consistent naming** -- packages referred to by the same name everywhere
- [ ] **Shared config** documented once, not duplicated across package docs
- [ ] **Cross-package links** resolve correctly

## Common Monorepo Doc Failures

1. **New package, no codemap entry** -- A new package was added but ARCHITECTURE.md wasn't updated
2. **Stale package count** -- "This monorepo contains 4 packages" when it now has 6
3. **Missing shared package docs** -- Shared/common packages are undocumented because "everyone knows what they do"
4. **Root-only docs** -- All docs live at the root, no package-level AGENTS.md files
5. **Port collisions undocumented** -- Services use non-standard ports to avoid collisions but this isn't documented
