---
name: move-input-to-nixzpkgs
description:
  Move a flake input from nixos-config's flake.nix into the nixZpkgs flake (~/git/nixZpkgs), re-export it there, and
  rewire nixos-config to use it. Use when asked to "move <input> to nixZpkgs".
---

# Move a flake input to nixZpkgs

`nixZpkgs` (`/home/zonni/git/nixZpkgs`, remote `gitea@git.tomato.local.zonni.pl:ZONIA/nixZpkgs.git`) aggregates
third-party inputs so `nix flake update` in nixos-config doesn't fetch them all. nixos-config consumes it as
`inputs.nixZpkgs`.

Argument: one or more input names from nixos-config's `flake.nix`.

## Steps

1. **Find usages** in nixos-config: `grep -rn "inputs\.<name>" --include='*.nix' .` (also `inputs'`/`"${inputs.<name>}"`
   path uses). Note which outputs are used: `nixosModules.*`, `overlays.*`, `packages.${system}.*`, `homeModules.*`, raw
   path. Check the input's real outputs with `nix flake show --no-write-lock-file <url>` if unsure.

2. **Copy the input to `nixZpkgs/flake.nix`** verbatim (url, `inputs.*.follows`). `nixpkgs` in nixZpkgs is the same
   channel as nixos-config's; keep `follows = "nixpkgs"` where it was. Keep a pinned rev/ref in the URL if the original
   had one.

3. **Re-export in `nixZpkgs/flake.nix`** (alphabetical within each group):
   - NixOS module → `nixosModules.<name>`; home-manager module → `homeModules.<name>`
   - overlay → `overlays.<name>` (one per input, never merged: nixos-config enables each separately via its own
     `overlays/<name>.nix`). Do NOT add it to `overlays.default` unless asked.
   - package → `packages.<name>` (flat, no per-system nesting; nixZpkgs is x86_64-linux only, using its `system`
     let-binding). Consumers use `inputs.nixZpkgs.packages.<name>` and need no `system` argument.
   - nested attrsets / raw source path (like nixos-hardware) → a custom top-level attr, with a short comment why.

4. **Lock**: `cd ~/git/nixZpkgs && nix flake lock`, then `nix flake show` to confirm the new outputs exist. If the user
   wants a specific rev, put it in the `flake.nix` URL (not only the lock) and re-lock.

5. **Rewire nixos-config**:
   - Remove the input block from `flake.nix`; the `nixZpkgs` input already exists, and nixos-config's `nixpkgs` follows
     `nixZpkgs/nixpkgs`.
   - Replace every `inputs.<name>.…` usage with the matching `inputs.nixZpkgs.…` path.
   - Overlay modules in `overlays/<name>.nix` stay separate files; only change the `overlay =` expression.
   - Do not touch unrelated code. If the input was unused, say so and just re-export it.

6. **Verify** without needing the push (nixZpkgs may be unpushed):

   ```
   nix eval --no-write-lock-file \
     --override-input nixZpkgs git+file:///home/zonni/git/nixZpkgs \
     .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath
   ```

   for hosts `corn`, `sesame`, `tomato`. If one fails, compare against `git stash` before blaming the move. Re-locking
   nixZpkgs can bump pins, so a changed drv path on a host is expected; mention it.

7. **Commit** (only if asked) in both repos, no body, no attribution lines unless told otherwise. nixos-config style:
   `(flake): move <name> to nixZpkgs` (look at `git log -50 --format=%s`). nixZpkgs: plain imperative, e.g.
   `Add <name>`. Never push without being told; remind the user of the order afterwards: push nixZpkgs →
   `nix flake lock` in nixos-config → commit.
