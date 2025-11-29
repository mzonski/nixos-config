{
  delib,
  host,
  config,
  homeManagerUser,
  pkgs,
  lib,
  ...
}:
let
  inherit (delib)
    module
    moduleOptions
    boolOption
    submodule
    strOption
    listOfOption
    attrsOption
    str
    enumOption
    attrsOfOption
    intOption
    ;
in
module {
  name = "services.network-share-server";

  options = moduleOptions {
    enable = boolOption false;
    enableSamba = boolOption true;
    enableNfs = boolOption true;
    workgroup = strOption "";
    serverString = strOption "";
    nfsAllowedNetworks = listOfOption str [ ];
    shares = attrsOfOption (submodule {
      options = {
        enableSamba = boolOption true;
        enableNfs = boolOption true;
        path = strOption "";
        type = enumOption [ "public" "protected" "private" ] "private";
        writeList = listOfOption str [ ];
        validUsers = listOfOption str [ ];
        sambaExtraConfig = attrsOption { };
        nfsExtraConfig = listOfOption str [ ];
      };
    }) { };
    nasGroups = attrsOfOption (submodule {
      options = {
        gid = intOption 0;
        extraMembers = listOfOption str [ ];
      };
    }) { };
  };

  myconfig.ifEnabled =
    { cfg, ... }:
    {
      user.groups = [
        "nogroup"
      ]
      ++ builtins.attrNames cfg.nasGroups;
    };

  nixos.ifEnabled =
    { cfg, ... }:
    {
      users.groups = lib.mapAttrs (name: groupCfg: {
        gid = groupCfg.gid;
        members = groupCfg.extraMembers;
      }) cfg.nasGroups;

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
          mkPublicShare =
            name: shareCfg:
            {
              path = shareCfg.path;
              "guest ok" = "yes";
              "guest account" = "nobody";
              "write list" = lib.concatStringsSep " " shareCfg.writeList;
              browseable = "yes";
              "read only" = "yes";
              "create mask" = "0644";
              "directory mask" = "0755";
            }
            // shareCfg.sambaExtraConfig;

          mkPrivateShare =
            name: shareCfg:
            {
              path = shareCfg.path;
              browseable = "no";
              "guest ok" = "no";
              "read only" = "no";
              "valid users" = lib.concatStringsSep " " shareCfg.validUsers;
              "create mask" = "0600";
              "directory mask" = "0700";
            }
            // shareCfg.sambaExtraConfig;

          mkProtectedShare =
            name: shareCfg:
            (mkPrivateShare name shareCfg)
            // {
              browseable = "yes";
            };

          mkShare =
            name: shareCfg:
            if shareCfg.type == "public" then
              mkPublicShare name shareCfg
            else if shareCfg.type == "protected" then
              mkProtectedShare name shareCfg
            else
              mkPrivateShare name shareCfg;

          sambaShares = lib.filterAttrs (name: shareCfg: shareCfg.enableSamba) cfg.shares;

        in
        {
          enable = true;
          openFirewall = true;

          settings = {
            global = {
              inherit (cfg) workgroup;
              "server string" = cfg.serverString;
              "netbios name" = host.name;

              "wins support" = "yes";
              "domain master" = "yes";
              "local master" = "yes";
              "preferred master" = "yes";
              "os level" = "65";

              "invalid users" = [
                "root"
              ];

              security = "user";
              "map to guest" = "bad user";
            };

            # media = mkPublicShare "/nas/media" "@nas-files @nas-torrents zonni";
            # files = mkProtectedShare "/nas/files" "zonni";
            # personal = mkPrivateShare "/nas/personal" "zonni";
          }
          // (lib.mapAttrs mkShare sambaShares);

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

      services.nfs = {
        settings = {
          nfsd = {
            vers2 = false;
            vers3 = false;
            vers4 = true;
          };
        };
        server =
          let
            nfsShares = lib.filterAttrs (name: shareCfg: shareCfg.enableNfs) cfg.shares;

            mkNfsExport =
              name: shareCfg:
              let
                allOptions = [
                  "rw"
                  "sync"
                  "no_subtree_check"
                  "no_root_squash"
                  "fsid=${toString (builtins.hashString "md5" name)}"
                ]
                ++ shareCfg.nfsExtraConfig;
                optionsStr = lib.concatStringsSep "," allOptions;

                mkNetworkExport = network: "${shareCfg.path} ${network}(${optionsStr})";
              in
              lib.concatMapStringsSep "\n" mkNetworkExport cfg.nfsAllowedNetworks;
          in
          {
            enable = true;
            exports = lib.concatStringsSep "\n" (lib.mapAttrsToList mkNfsExport nfsShares);
            hostName = host.name;

          };
      };

      networking.firewall = {
        allowedTCPPorts = [
          2049 # nfs
          111 # rpcbind
        ];
      };
    };
}
