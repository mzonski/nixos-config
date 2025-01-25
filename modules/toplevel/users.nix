# {
#   config,
#   options,
#   lib,
#   lib',
#   ...
# }:
# let
#   inherit (lib) types mkOption mkAliasDefinitions;
#   inherit (lib') mkOpt;
# in

# {
#   options.host = with types; {
#     admin = mkOption {
#       type = types.str;
#       description = "Main username";
#       example = "zonni";
#     };

#     domain = mkOption {
#       type = types.str;
#       description = "Domain to connect to";
#       example = "local.zonni.pl";
#     };

#     user = mkOpt attrs { };
#   };

#   config =
#     let
#       ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
#       inherit (config.host) admin domain;
#     in
#     {
#       host.user = {
#         createHome = true;
#         isNormalUser = true;
#         uid = 1000;
#         group = admin;
#         home = "/home/${admin}";
#         extraGroups = ifTheyExist [
#           "wheel"
#           "deluge"
#           "docker"
#           "git"
#           "i2c"
#           "network"
#           "plugdev"
#           "wireshark"
#           "audio"
#         ];
#         openssh.authorizedKeys.keys = lib.splitString "\n" (builtins.readFile ../../homes/${admin}/ssh.pub);
#         hashedPasswordFile = config.sops.secrets."${admin}-password".path;
#       };

#       users.mutableUsers = false;
#       users.users.${admin} = mkAliasDefinitions options.host.user;
#       users.groups.${admin} = { };

#       sops.secrets."${admin}-password" = {
#         sopsFile = ../../shared-secrets.yaml;
#         neededForUsers = true;
#       };

#       networking.domain = domain;

#       security.sudo.extraRules = [
#         {
#           users = [ admin ];
#           commands = [
#             {
#               command = "ALL";
#               options = [ "NOPASSWD" ];
#             }
#           ];
#         }
#       ];

#       nix.settings =
#         let
#           users = [
#             "root"
#             admin
#           ];
#         in
#         {
#           trusted-users = users;
#           allowed-users = users;
#         };
#     };
# }
{ }
