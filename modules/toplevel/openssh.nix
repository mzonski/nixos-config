{
  delib,
  lib,
  config,
  homeManagerUser,
  ...
}:
let
  machineKeyFile = "/etc/ssh/ssh_host_ed25519_key";
in
delib.module {
  name = "keys";

  options.keys = with delib; {
    ssh = attrsOfOption path { };
    gpg = attrsOfOption path { };
  };

  nixos.always =
    { cfg, myconfig, ... }:
    let
      hostnames = builtins.attrNames myconfig.hosts;
      otherMachineHostNames = lib.filter (hostname: hostname != config.networking.hostName) hostnames;
    in
    {

      sops.secrets = {
        "ssh_private_zonni" = {
          path = "/home/${homeManagerUser}/.ssh/id_ed25519";
          mode = "0600";
          owner = homeManagerUser;
          group = homeManagerUser;
        };
        "ssh_public_zonni" = {
          path = "/etc/ssh/authorized_keys.d/${homeManagerUser}";
          mode = "0640";
          owner = homeManagerUser;
          group = homeManagerUser;
        };
      }
      // lib.listToAttrs (
        # TODO: exclude server from desktop
        map (hostname: {
          name = "ssh_public_${hostname}";
          value = {
            path = "/etc/ssh/authorized_keys.d/${hostname}";
            mode = "0640";
            owner = "root";
            group = "root";
          };
        }) otherMachineHostNames
      );

      services.openssh = {
        enable = true;

        settings = {
          PasswordAuthentication = false;
          PermitRootLogin = "yes";

          StreamLocalBindUnlink = "yes";
          GatewayPorts = "clientspecified";
          AcceptEnv = "WAYLAND_DISPLAY";
          X11Forwarding = true;
        };

        hostKeys = [
          {
            path = machineKeyFile;
            type = "ed25519";
          }
        ];
      };

      networking.firewall.allowedTCPPorts = [ 22 ];

      programs.ssh =
        let
          extraHostConfig = lib.concatStringsSep "\n" (
            (map (hostname: ''
              Host ${hostname}
                HostName ${hostname}
                User root
                IdentityFile ${machineKeyFile}
            '') otherMachineHostNames)
            ++ [
              ''
                Host seed
                  HostName seed
                  User root
                  IdentityFile ${machineKeyFile}
              ''
            ]
          );
        in
        {
          extraConfig = extraHostConfig + ''
            Host seed
              HostName seed
              User nixos
              IdentityFile ~/.ssh/id_ed25519
          '';
        };

      security.pam.sshAgentAuth = {
        enable = true;
        authorizedKeysFiles = [ "/etc/ssh/authorized_keys.d/%u" ];
      };
    };

  home.always =
    { myconfig, ... }:
    let
      hostnames = builtins.attrNames myconfig.hosts;
    in
    {
      programs.ssh = {
        enable = true;

        matchBlocks =
          lib.genAttrs hostnames (hostname: {
            inherit hostname;
            user = homeManagerUser;
            identityFile = "~/.ssh/id_ed25519";
          })
          // {
            "seed" = {
              hostname = "seed";
              user = "nixos";
              identityFile = "~/.ssh/id_ed25519";
            };
          };

      };
    };
}
