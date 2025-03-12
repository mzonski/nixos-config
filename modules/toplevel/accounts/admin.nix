{
  lib,
  delib,
  homeManagerUser,
  ...
}:
let
  inherit (lib) mkIf mkMerge;
  inherit (delib) strOption boolOption;
in
delib.module {
  name = "admin";

  options.admin = {
    username = strOption "zonni";
    disableSudoPasswordRequirement = boolOption true;
  };

  myconfig.always =
    { cfg, ... }:
    let
      inherit (cfg) username;
      isAdmin = homeManagerUser == username;
    in
    {
      user.groups = mkIf isAdmin [
        "wheel"
        "adm"
      ];
    };

  nixos.always =
    { cfg, ... }:
    let
      inherit (cfg) username disableSudoPasswordRequirement;
      isAdmin = homeManagerUser == username;
    in
    {
      security.sudo.extraRules = mkIf disableSudoPasswordRequirement [
        {
          users = [ username ];
          commands = [
            {
              command = "ALL";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];

      nix.settings =
        let
          users = mkMerge [
            [
              "root"
            ]
            (mkIf isAdmin [ username ])
          ];
        in
        {
          trusted-users = users;
          allowed-users = users;
        };

      # Increase open file limit for sudoers
      security.pam.loginLimits = [
        {
          domain = "@wheel";
          item = "nofile";
          type = "soft";
          value = "524288";
        }
        {
          domain = "@wheel";
          item = "nofile";
          type = "hard";
          value = "1048576";
        }
      ];
    };
}
