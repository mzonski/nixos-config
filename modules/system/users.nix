{
  config,
  options,
  lib,
  mylib,
  pkgs,
  ...
}:

with lib;
with mylib;
{
  options.sys = with types; {
    username = mkOption {
      type = types.str;
      description = "Main username";
      example = "zonni";
    };

    domain = mkOption {
      type = types.str;
      description = "Domain to connect to";
      example = "local.zonni.pl";
    };

    user = mkOpt attrs { };
  };

  config =
    let
      ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
      inherit (config.sys) username domain;
    in
    {
      sys.user = {
        createHome = true;
        isNormalUser = true;
        uid = 1000;
        group = username;
        home = "/home/${username}";
        extraGroups = ifTheyExist [
          "wheel"
          "deluge"
          "docker"
          "git"
          "i2c"
          "network"
          "plugdev"
          "wireshark"
        ];
        initialPassword = "nixos";
      };

      users.mutableUsers = true;
      users.users.${username} = mkAliasDefinitions options.sys.user;
      users.groups.${username} = { };

      networking.domain = domain;

      security.sudo.extraRules = [
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
          users = [
            "root"
            username
          ];
        in
        {
          trusted-users = users;
          allowed-users = users;
        };
    };
}
