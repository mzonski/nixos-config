{
  delib,
  host,
  config,
  homeManagerUser,
  pkgs,
  ...
}:
let
  inherit (delib)
    module
    moduleOptions
    boolOption
    ;
in
module {
  name = "services.samba";

  options = moduleOptions {
    enable = boolOption false;
  };

  nixos.ifEnabled =
    { cfg, ... }:
    {
      users.groups.nas-public = {
        gid = 2001;
        members = [
          "nobody"
          homeManagerUser
        ];
      };
      users.groups.nas-files = {
        gid = 2002;
        members = [ homeManagerUser ];
      };
      users.groups.nas-torrents = {
        gid = 2003;
        members = [ homeManagerUser ];
      };

      sops.secrets = {
        "samba_password" = {
          sopsFile = host.secretsFile;
          mode = "0400";
          owner = "root";
          group = "root";
        };
      };

      system.activationScripts.init_smbpasswd = {
        text =
          let
            defaultSambaPasswordPath = config.sops.secrets.samba_password.path;
            adminUsername = homeManagerUser;
          in
          ''
            password=$(${pkgs.coreutils}/bin/cat ${defaultSambaPasswordPath})
            ${pkgs.coreutils}/bin/printf "%s\n%s\n" "$password" "$password" | \
              ${pkgs.samba}/bin/smbpasswd -sa ${adminUsername} -s
          '';
      };

      services.samba =
        let
          mkPublicShare = path: writeList: {
            inherit path;
            "guest ok" = "yes";
            "guest account" = "nobody";
            "write list" = writeList;
            browseable = "yes";
            "read only" = "yes";
            "create mask" = "0644";
            "directory mask" = "0755";
          };

          mkPrivateShare = path: validUsers: {
            inherit path;
            browseable = "no";
            "guest ok" = "no";
            "read only" = "no";
            "valid users" = validUsers;
            "create mask" = "0600";
            "directory mask" = "0700";
          };

          mkProtectedShare =
            path: user:
            (mkPrivateShare path user)
            // {
              browseable = "yes";
            };

        in
        {
          enable = true;
          openFirewall = true;

          settings = {
            global = {
              workgroup = "HOMELAB";
              "server string" = "Homelab NAS";
              "netbios name" = host.name;

              "wins support" = "yes";
              "local master" = "yes";
              "preferred master" = "yes";
              "os level" = "65";

              "invalid users" = [
                "root"
              ];

              security = "user";
              "map to guest" = "bad user";
            };

            media = mkPublicShare "/nas/media" "@nas-files @nas-torrents zonni";
            files = mkProtectedShare "/nas/files" "zonni";
            personal = mkPrivateShare "/nas/personal" "zonni";
          };

          nmbd.enable = true;
          winbindd.enable = false;
        };

      services.samba-wsdd = {
        enable = true;
        openFirewall = true;
      };

      services.avahi = {
        enable = true;
        nssmdns4 = false;
        publish = {
          enable = true;
          addresses = true;
          workstation = true;
        };
      };
    };
}
