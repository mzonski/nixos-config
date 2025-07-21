{
  delib,
  inputs,
  lib,
  pkgs,
  config,
  homeManagerUser,
  ...
}:
delib.module {
  name = "keys";

  options.keys = with delib; {
    ssh = attrsOfOption path { };
    gpg = attrsOfOption path { };
  };

  myconfig.always =
    { cfg, myconfig, ... }:
    let
      inherit (builtins)
        attrNames
        readDir
        filter
        listToAttrs
        pathExists
        ;
      hostnames = attrNames myconfig.hosts;

      makeKeyPaths =
        {
          basePath,
          names,
          suffix,
        }:
        listToAttrs (
          map (name: {
            inherit name;
            value = "${basePath}/${name}/${suffix}";
          }) (filter (name: pathExists "${basePath}/${name}/${suffix}") names)
        );

      userDirs =
        let
          dirs = readDir ../../keys/users;
          dirPaths = lib.mapAttrsToList (name: type: {
            inherit name type;
            path = ../../keys/users + "/${name}";
          }) dirs;
        in
        filter (x: x.type == "directory") dirPaths;

      userNames = map (dir: dir.name) userDirs;
    in
    {
      keys.ssh =
        (makeKeyPaths {
          basePath = ../../keys/hosts;
          names = hostnames;
          suffix = "ssh.pub";
        })
        // (makeKeyPaths {
          basePath = ../../keys/users;
          names = userNames;
          suffix = "ssh.pub";
        });

      keys.gpg = makeKeyPaths {
        basePath = ../../keys/users;
        names = userNames;
        suffix = "pgp.asc";
      };
    };

  nixos.always =
    { cfg, myconfig, ... }:
    let
      isEd25519 = k: k.type == "ed25519";
      getKeyPath = k: k.path;
      keys = builtins.filter isEd25519 config.services.openssh.hostKeys;
      hostnames = builtins.attrNames myconfig.hosts;
    in
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      sops = {
        defaultSopsFile = ../../shared-secrets.yaml;
        age.sshKeyPaths = map getKeyPath keys;
      };

      environment.systemPackages = [ pkgs.sops ];

      services.openssh = {
        settings = {
          # Harden
          PasswordAuthentication = false;
          PermitRootLogin = "no";

          # Automatically remove stale sockets
          StreamLocalBindUnlink = "yes";
          # Allow forwarding ports to everywhere
          GatewayPorts = "clientspecified";
          # Let WAYLAND_DISPLAY be forwarded
          AcceptEnv = "WAYLAND_DISPLAY";
          X11Forwarding = true;
        };

        # knownHosts = lib.mapAttrs (hostname: pubkeyFile: {
        #   publicKeyFile = pubkeyFile;
        #   hostNames = [
        #     hostname
        #     "${hostname}.local.zonni.pl"
        #   ] ++ (lib.optional (hostname == config.networking.hostName) "localhost");
        # }) cfg.ssh;

        hostKeys = [
          {
            path = "/etc/ssh/ssh_host_ed25519_key";
            type = "ed25519";
          }
        ];
      };

      programs.ssh =
        let
          extraHostConfig = builtins.toFile "home_host_entries" (
            lib.concatStringsSep "\n" (
              map (
                hostname:
                lib.optionalString (hostname != config.networking.hostName) ''
                  Host ${hostname}
                    HostName ${hostname}
                    User root
                    IdentityFile /etc/ssh/ssh_host_ed25519_key
                ''
              ) hostnames
            )
          );
        in
        {
          knownHosts = lib.genAttrs hostnames (hostname: {
            publicKeyFile = cfg.ssh.${hostname};
            extraHostNames =
              [ "${hostname}.local.zonni.pl" ]
              ++
              # Alias for localhost if it's the same host
              (lib.optional (hostname == config.networking.hostName) "localhost");

          });

          extraConfig = ''
            Include ${extraHostConfig}
          '';
        };

      # Passwordless sudo when SSH'ing with keys
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

        matchBlocks = lib.genAttrs hostnames (hostname: {
          inherit hostname;
          user = homeManagerUser;
          identityFile = "~/.ssh/id_ed25519";
        });
      };
    };

  # templates are not yet implemented in sops-nix for home-manager
  # home.always =
  #   { cfg, ... }:
  #   let
  #     inherit (lib) toString;
  #   in
  #   {
  #     imports = [ inputs.sops.homeManagerModule ];

  #     sops = {
  #       defaultSopsFile = ../../secrets.yaml;
  #       defaultSopsFormat = "yaml";
  #       age.keyFile = toString /${homeconfig.home.homeDirectory}/.config/sops/age/keys.txt;
  #       inherit (cfg) secrets;
  #     };

  #     home.packages = [ pkgs.sops ];
  #   };
}
