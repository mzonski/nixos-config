{
  delib,
  pkgs,
  homeManagerUser,
  config,
  host,
  lib,
  ...
}:

let
  inherit (delib)
    module
    boolOption
    moduleOptions
    intOption
    strOption
    ;

  user = "qbittorrent";
  group = "nas-files";
in
module {
  name = "services.qbittorrent";

  options = moduleOptions {
    enable = boolOption false;
    port = intOption 6881;
    uiPort = intOption 8081;
    profileDir = strOption "/var/lib/qBittorrent";
    downloadsDir = strOption "/nas/media/Torrents";
    defaultNetwork = strOption "br-vpn";
  };

  myconfig.ifEnabled =
    { cfg, ... }:
    {
      homelab.reverse-proxy.qbittorrent = {
        port = cfg.uiPort;
        subdomain = "torrent";
        root = true;
      };
    };

  nixos.ifEnabled =
    { cfg, ... }:
    let
      configLocation = "${cfg.profileDir}/qBittorrent/config/qBittorrent.conf";
      tempDir = "${cfg.downloadsDir}/_temp";
      entries = [
        "g:${group}:rwX"
        "u:${user}:rwX"
        "u:${homeManagerUser}:rwX"
      ];
      acl = lib.concatStringsSep "," (entries ++ map (e: "d:${e}") entries);
    in
    {
      sops = {
        secrets.qbittorrent_password = {
          sopsFile = host.secretsFile;
        };
        templates.qbittorrent-password-config = {
          content = ''
            [Preferences]
            WebUI\Password_PBKDF2="${config.sops.placeholder.qbittorrent_password}"
          '';
          owner = user;
          inherit group;
          path = "${cfg.profileDir}/password.conf";
        };
      };

      # Owned by the parent's owner (not qbittorrent): systemd-tmpfiles refuses to
      # chown/set ACLs across a zonni -> qbittorrent ownership change in the path.
      # qbittorrent gets its access through the ACL instead.
      systemd.tmpfiles.rules = [
        "d ${cfg.downloadsDir} - ${homeManagerUser} ${group} - -"
        "a+ ${cfg.downloadsDir} - - - - ${acl}"
        "d ${tempDir} - ${homeManagerUser} ${group} - -"
        "a+ ${tempDir} - - - - ${acl}"
      ];

      systemd.services.qbittorrent = {
        after = [ "zfs.target" ];
        requires = [ "zfs.target" ];

        serviceConfig = {
          RestrictNetworkInterfaces = [
            "lo"
            "${cfg.defaultNetwork}"
          ];
          UMask = "0002";
          ExecStartPre = lib.mkAfter [
            (pkgs.writeShellScript "insert-qbittorrent-password" ''
              chmod 744 ${configLocation}
              ${pkgs.gnused}/bin/sed -i '/# BEGIN PASSWORD INSERT/,/# END PASSWORD INSERT/d' ${configLocation}
              ${pkgs.gnused}/bin/sed -i '/^WebUI\\Password_PBKDF2=/d' ${configLocation}

              echo "# BEGIN PASSWORD INSERT" >> ${configLocation}
              cat ${config.sops.templates.qbittorrent-password-config.path} >> ${configLocation}
              echo "# END PASSWORD INSERT" >> ${configLocation}
              chmod 744 ${configLocation}
            '')
          ];
        };
      };

      services.qbittorrent = {
        enable = true;
        package = pkgs.qbittorrent-nox;

        openFirewall = true;
        torrentingPort = cfg.port;
        webuiPort = cfg.uiPort;
        profileDir = cfg.profileDir + "/";

        inherit user group;

        extraArgs = [ "--confirm-legal-notice" ];

        serverConfig = {
          Application = {
            FileLogger = {
              Age = 1;
              AgeType = 1;
              Backup = true;
              DeleteOld = true;
              Enabled = true;
              MaxSizeBytes = 66560;
              Path = "${cfg.profileDir}/qBittorrent/data/logs";
            };
          };

          BitTorrent = {
            Session = {
              AddExtensionToIncompleteFiles = true;
              AddTorrentStopped = false;
              DefaultSavePath = cfg.downloadsDir;
              ExcludedFileNames = "";
              GlobalMaxRatio = 0;
              Interface = "br-vpn";
              InterfaceAddress = "10.0.2.3";
              InterfaceName = cfg.defaultNetwork;
              Port = cfg.port;
              QueueingSystemEnabled = true;
              SSL.Port = 42719;
              ShareLimitAction = "Stop";
              TempPath = tempDir;
              TempPathEnabled = true;
            };
          };

          Core = {
            AutoDeleteAddedTorrentFile = "Never";
          };

          LegalNotice = {
            Accepted = true;
          };

          Network = {
            Proxy = {
              HostnameLookupEnabled = false;
              Profiles = {
                BitTorrent = true;
                Misc = false;
                RSS = false;
              };
            };
          };

          Preferences = {
            General.Locale = "en";
            MailNotification.req_auth = true;
            WebUI = {
              Address = "127.0.0.1";
              AuthSubnetWhitelist = "10.0.1.50/32";
              AuthSubnetWhitelistEnabled = false;
              Port = cfg.uiPort;
              Username = homeManagerUser;
              CSRFProtection = false;
              HostHeaderValidation = false;
              LocalHostAuth = false;
              ReverseProxySupportEnabled = true;
              TrustedReverseProxiesList = "0.0.0.0/24";
              SecureCookie = false;

              AlternativeUIEnabled = true;
              RootFolder = "${pkgs.vuetorrent}/share/vuetorrent";
            };
          };
        };
      };
    };
}
