# AGENTS.md

Guidance for AI agents working in this repository.

## Repository overview

`my-cursor` is currently a **minimal stub**: the only tracked source file is `README.md`. There is no application code, package manifest, Docker setup, or test harness in this tree.

## Cursor Cloud specific instructions

- **Dependencies**: None. No `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, or similar exists. The VM update script is intentionally a no-op.
- **Services**: Nothing to run. There are no dev servers, databases, or compose stacks documented or present.
- **Lint / test / build**: No scripts or tooling are configured. Do not expect `npm test`, `make lint`, etc. to exist until the project adds them.
- **Typical agent work**: Editing documentation, scaffolding new code, or syncing content from another repo/branch—verify the checkout actually contains the code you need before assuming services exist.

When this repo grows into a real application, update this section with the non-obvious startup and test caveats (not dependency install steps—that belongs in the update script).
