{
  delib,
  inputs,
  pkgs,
  config,
  ...
}:
delib.module {
  name = "sops";

  nixos.always =
    { cfg, myconfig, ... }:
    let
      isEd25519 = k: k.type == "ed25519";
      hostKeys = builtins.filter isEd25519 config.services.openssh.hostKeys;
    in
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      environment.systemPackages = [ pkgs.sops ];

      sops = {
        defaultSopsFile = ../../shared-secrets.yaml;
        age.sshKeyPaths = map (key: key.path) hostKeys;
      };
    };
}
