{
  delib,
  pkgs,
  homeManagerUser,
  config,
  host,
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
in
module {
  name = "services.qbittorrent";

  options = moduleOptions {
    enable = boolOption false;
    port = intOption 6881;
    uiPort = intOption 8081;
    profileDir = strOption "/var/lib/qBittorrent";
    downloadsDir = strOption "/nas/media/Torrents";
  };

  myconfig.ifEnabled =
    { cfg, ... }:
    {
      homelab.reverse-proxy.qbittorrent = {
        port = cfg.uiPort;
        subdomain = "torrent";
      };
    };

  nixos.ifEnabled =
    { cfg, ... }:
    let
      configLocation = "${cfg.profileDir}/qBittorrent/config/qBittorrent.conf";
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
          owner = "qbittorrent";
          group = "nas-torrents";
          path = "${cfg.profileDir}/password.conf";
        };
      };

      systemd.services.qbittorrent = {
        serviceConfig = {
          UMask = "0002";
          ExecStartPre = pkgs.writeShellScript "insert-qbittorrent-password" ''
            chmod 744 ${configLocation}
            ${pkgs.gnused}/bin/sed -i '/# BEGIN PASSWORD INSERT/,/# END PASSWORD INSERT/d' ${configLocation}
            ${pkgs.gnused}/bin/sed -i '/^WebUI\\Password_PBKDF2=/d' ${configLocation}

            echo "# BEGIN PASSWORD INSERT" >> ${configLocation}
            cat ${config.sops.templates.qbittorrent-password-config.path} >> ${configLocation}
            echo "# END PASSWORD INSERT" >> ${configLocation}
            chmod 744 ${configLocation}
          '';
        };
      };

      services.qbittorrent = {
        enable = true;
        package = pkgs.qbittorrent-nox;

        openFirewall = true;
        torrentingPort = cfg.port;
        webuiPort = cfg.uiPort;
        profileDir = cfg.profileDir + "/";

        user = "qbittorrent";
        group = "nas-torrents";

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
              InterfaceName = "br102";
              Port = cfg.port;
              QueueingSystemEnabled = true;
              SSL.Port = 42719;
              ShareLimitAction = "Stop";
              TempPath = "${cfg.downloadsDir}/_temp";
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
              LocalHostAuth = true;
              ReverseProxySupportEnabled = true;
              TrustedReverseProxiesList = "0.0.0.0/24";
              SecureCookie = false;
            };
          };
        };
      };
    };
}
