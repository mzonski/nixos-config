{
  delib,
  pkgs,
  ...
}:

let
  inherit (delib)
    module
    boolOption
    moduleOptions
    ;
in
module {
  name = "services.qbittorrent";

  options = moduleOptions {
    enable = boolOption false;
  };

  nixos.ifEnabled =
    { cfg, ... }:
    {
      systemd.services.qbittorrent = {
        serviceConfig = {
          UMask = "0002";
        };
      };

      services.qbittorrent = {
        enable = true;
        package = pkgs.qbittorrent-nox;

        openFirewall = true;
        torrentingPort = 6881;
        webuiPort = 8081;

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
              Path = "/var/lib/qBittorrent/qBittorrent/data/logs";
            };
          };

          BitTorrent = {
            Session = {
              AddExtensionToIncompleteFiles = true;
              AddTorrentStopped = false;
              DefaultSavePath = "/nas/media/Torrents";
              ExcludedFileNames = "";
              GlobalMaxRatio = 0;
              Interface = "br102";
              InterfaceAddress = "10.0.2.3";
              InterfaceName = "br102";
              Port = 6881;
              QueueingSystemEnabled = true;
              SSL.Port = 42719;
              ShareLimitAction = "Stop";
              TempPath = "/nas/media/Torrents/_temp";
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
              Address = "10.0.1.3";
              AuthSubnetWhitelist = "10.0.1.50/32";
              AuthSubnetWhitelistEnabled = true;
              Port = 8081;
              Username = "zonni";
            };
          };
        };
        profileDir = "/var/lib/qBittorrent/";

      };
    };
}
