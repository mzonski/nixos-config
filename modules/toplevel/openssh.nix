# {
#   config,
#   lib,
#   ...
# }:

# let
#   enabled = config.services.openssh.enable;

#   inherit (lib) mkIf genAttrs filterAttrs;
#   inherit (builtins) attrNames readDir;

#   dirNames = attrNames (filterAttrs (name: type: type == "directory") (readDir ../../hosts));
# in
# {
#   config = mkIf enabled {
#     services.openssh = {
#       settings = {
#         # Harden
#         PasswordAuthentication = false;
#         PermitRootLogin = "no";

#         # Automatically remove stale sockets
#         StreamLocalBindUnlink = "yes";
#         # Allow forwarding ports to everywhere
#         GatewayPorts = "clientspecified";
#         # Let WAYLAND_DISPLAY be forwarded
#         AcceptEnv = "WAYLAND_DISPLAY";
#         X11Forwarding = true;
#       };

#       hostKeys = [
#         {
#           path = "/etc/ssh/ssh_host_ed25519_key";
#           type = "ed25519";
#         }
#       ];
#     };

#     programs.ssh = {
#       knownHosts = genAttrs dirNames (hostname: {
#         publicKeyFile = ../../hosts/${hostname}/ssh_host_ed25519_key.pub;
#         extraHostNames =
#           [
#             "${hostname}.local.zonni.pl"
#           ]
#           ++
#           # Alias for localhost if it's the same host
#           (lib.optional (hostname == config.networking.hostName) "localhost");
#       });
#     };

#     # Passwordless sudo when SSH'ing with keys
#     security.pam.sshAgentAuth = {
#       enable = true;
#       authorizedKeysFiles = [ "/etc/ssh/authorized_keys.d/%u" ];
#     };
#   };
# }
{ }
