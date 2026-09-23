# Toolbox smoke tests

Minimal devenv consumers under `toolboxes/_smoke_tests/`. The underscore
prefix marks this tree as meta: it is not itself an importable toolbox.

Each subdirectory imports **one** pure toolbox the way a real project
would (`imports: [/toolboxes/<name>]`). Transitive inputs and imports
come from that toolbox's own `devenv.yaml`.

These fixtures replace the old habit of treating a language toolbox
directory as a half-project just to try it.

## How to run one smoke test

From a machine with devenv + nix (Jesse's workplace):

```bash
cd toolboxes/_smoke_tests/python   # or any other fixture
devenv shell -- ./check.sh
```

Pass means `check.sh` exits 0. That implies the shell entered, enterShell
tasks ran (templates / PATH seeds), and the checks in that fixture's
`check.sh` succeeded.

If flake inputs need a GitHub token (common for toolboxes that pull
agent/skill repos), use the secrets toolbox helper or set Nix access
tokens the same way you do for normal projects:

```bash
# after secrets toolbox has seeded tooling, or via your usual wrapper:
NIX_CONFIG="access-tokens = github.com=$NIX_GITHUB_PAT" devenv shell -- ./check.sh
```

### Unfree packages (`bws`)

devenv applies `nixpkgs.permitted_unfree_packages` / `allow_unfree` on the
**project root** only. A permit inside an imported toolbox (e.g. `secrets`
for `bws`) does not reliably merge into a smoke consumer.

Fixtures that import `secrets` directly or transitively (`ai`, `bdd`,
`code`, `python`, `secrets`) therefore declare:

```yaml
nixpkgs:
  permitted_unfree_packages:
    - bws
```

in their own `devenv.yaml`. Real projects that import those toolboxes need
the same root permit.

### Secrets / XAI

Toolboxes that import `secrets` (and language/AI stacks that vendor
skills) may seed a `secretspec.toml` into the smoke dir on shell entry.
That file is gitignored here.

For full AI/skill behavior you typically need:

- `TEST_SECRET` (secrets smoke / shared profile)
- `XAI_API_KEY` (ai / python / bdd / code and anything that pulls ai)

Provide them via secretspec + BWS the same way real projects do
(`secretspec check`). Do **not** commit real secrets.

Shell entry itself does not currently require secretspec to succeed
(secretspec is packaged and templated; it is not forced on by devenv
`secretspec.enable` in these toolboxes). Smoke checks that only need
PATH/tools/templates can pass without XAI.

## Fixtures

| Fixture | Imports | Pass highlights |
| --- | --- | --- |
| `ai/` | `/toolboxes/ai` | enterShell; `.eca` agent/config seeded |
| `bdd/` | `/toolboxes/bdd` | enterShell; BDD agents/skills seeds |
| `code/` | `/toolboxes/code` | `opencode` on PATH; code seeds |
| `emacs/` | `/toolboxes/emacs` | `.envrc` + `.dir-locals.el` seeded |
| `git/` | `/toolboxes/git` | merged root `.gitignore` present |
| `html/` | `/toolboxes/html` | html/css LS + prettier; `index.html` |
| `javascript/` | `/toolboxes/javascript` | node/npm/tsc; `package.json` |
| `project_management/` | `/toolboxes/project_management` | requires local `project_name`; dir-locals fragment |
| `python/` | `/toolboxes/python` | python/uv/ruff/ty; `pyproject.toml` |
| `racket/` | `/toolboxes/racket` | racket/raco on PATH |
| `readme/` | `/toolboxes/readme` | readme.org template under `.toolboxes/` |
| `rust/` | `/toolboxes/rust` | rustc/cargo; `Cargo.toml` |
| `secrets/` | `/toolboxes/secrets` | `bws` + `secretspec` on PATH; secretspec.toml seeded |
| `voxtype/` | `/toolboxes/voxtype` | enterShell succeeds |

## Not smoke-tested here

- **`old_ai`** — legacy predecessor of `ai`; left alone on purpose.
- **`toolboxes/` root devenv** — aggregator / playground, not a toolbox module.
- **`_smoke_tests` itself** — meta only; never import it as a toolbox.

If a toolbox later requires options or non-optional secrets to enter the
shell, either extend that fixture's `devenv.nix` / docs or call out the
blocker in this README instead of leaving a broken consumer.
