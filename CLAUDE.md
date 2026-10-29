# nixos-config

Flake for my NixOS hosts, built with Denix. Hosts: `corn` (desktop), `sesame` (laptop), `tomato` (homelab server),
`seed` (install ISO), `graft-<host>` (live recovery ISO of a host). `flake.nix` feeds `hosts/`, `rices/`, `modules/`
and `overlays/` to `denix.lib.configurations`, which auto-imports every `.nix` file.

## Commands

- Verify a change (no sudo, applies nothing):
  `nix eval --raw .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath`. Use
  `nixos-rebuild build --flake .#<host>` for a full build.
- Format: `nixfmt <file>`.
- Don't run `make system`, `make home`, `deploy-%`, `sysboot-%` or any `switch`/`boot` target unless asked. They change
  live machines. All targets are in `Makefile`.

## Rules

- Always write new config as a **Denix module** (`delib.module`), never a plain NixOS or home-manager module. Plain Nix
  is only for `packages/` (callPackage) and `lib/`/`utils/` helpers. Details: `.claude/rules/denix.md`.
- New third-party flake inputs go into nixZpkgs, not `flake.nix`. Use the `move-input-to-nixzpkgs` skill.
- Flakes only see files tracked by git, so `git add` new files before eval or build.

## Gotchas

- `hosts/*/hardware-configuration.nix` is generated. Don't edit it.
- Secrets use sops. Use `shared-secrets.yaml` for all hosts and `hosts/<host>/secrets.yaml` (exposed as
  `host.secretsFile`) for one host. Recipients live in `.sops.yaml`. Never decrypt or print secrets.
- `seed` builds only via `make seed-iso` / `make seed-debug`: it needs `--impure` plus SSH env vars (`lib/env.nix`).
- `graft-<host>` is the host's own config extended with `special/graft/` (via `extendModules`, so it is not in
  `myconfig.hosts`). Build only via `make graft-iso-<host>`: it injects that host's SSH host key
  (`ssh_private_<host>` / `ssh_public_<host>` from `shared-secrets.yaml`), like `seed-iso`.
- `pkgs.local.<dir>` holds packages from `packages/<dir>/`, and `pkgs.unstable.<x>` holds nixos-unstable packages (see
  `overlays/`).

## References (read when relevant)

- Denix source and docs: `~/git/denix` (`docs/src/`, `lib/`). This is my fork; the flake pins upstream
  `github:yunfachi/denix`, so `flake.lock` decides the real version.
- Custom Denix extensions (host and rice options, helper functions): `extensions/`.
- nixZpkgs (aggregated inputs): `~/git/nixZpkgs`, with its own `CLAUDE.md`.
