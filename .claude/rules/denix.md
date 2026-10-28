---
paths:
  - "**/*.nix"
---

# Writing Denix modules

## Shape
- Use `delib.module { name = "a.b"; options = ...; myconfig/nixos/home.{ifEnabled,ifDisabled,always} = ...; }`.
- `name` must equal the option path, because `cfg` resolves to `myconfig.<name>`.
- Options: `singleEnableOption false` when the module only needs `enable`, otherwise
  `moduleOptions { enable = boolOption false; ... }`. Option builders come from `delib`
  (`strOption`, `intOption`, `listOfOption str [ ]`, `noDefault`, `allowNull`, `submodule`…).
- Lambdas get `{ cfg, myconfig, parent, name, ... }`. `host` (`host.name`,
  `host.secretsFile`, `host.isDesktop`/`isServer`/`isMinimal`) comes from the file's
  top-level args.
- `home.*` targets the home-manager user (`homeManagerUser`: `zonni`, or `nixos` on `seed`).
  Don't write `home-manager.users.*` by hand.
- **Imports go in `[nixos|home].always.imports`**, never under `ifEnabled`, which causes
  infinite recursion.
- Overlays: one `delib.overlayModule { name; overlay; }` per file in `overlays/`.
- Hosts are `delib.host` (`hosts/<name>/configuration.nix`) and set features via `myconfig`.
  Rices are `delib.rice` (`rices/`).

## Local conventions
- Pull the helpers you need into a `let inherit (delib) ...;` block, like the existing files do.
- Custom helpers (`assertEnabled`, `isHomelabEnabled`, `strings.ensureTrailingSlash`) are in
  `extensions/custom-functions.nix`. Extra host and rice options are in `extensions/extend-*.nix`.
- A homelab service registers itself through `myconfig.ifEnabled`: `homelab.reverse-proxy.<svc>`,
  `homelab.db.<svc>` and `homelab.users.*`. Copy `modules/services/gitea.nix`.

## Where to look
- Module, host and rice structure: `~/git/denix/docs/src/{modules,hosts,rices}/structure.md`
- Option builders: `~/git/denix/docs/src/options/introduction.md`, and the full list in
  `~/git/denix/lib/options.nix`
- Extensions (args, base, overlays): `~/git/denix/docs/src/extensions/all-extensions.md`
- Common errors: `~/git/denix/docs/src/troubleshooting.md`
