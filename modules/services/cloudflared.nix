{
  lib,
  delib,
  host,
  config,
  pkgs,
  ...
}:
let
  inherit (delib)
    module
    moduleOptions
    boolOption
    strOption
    noDefault
    ;
  inherit (lib) mapAttrs' nameValuePair;
  package = pkgs.unstable.cloudflared;
in
module {
  name = "services.cloudflared";

  options = moduleOptions {
    enable = boolOption false;
    tunnelId = noDefault (strOption null);
  };

  nixos.ifEnabled =
    { cfg, ... }:
    {
      environment.systemPackages = [
        (pkgs.writeShellScriptBin "cloudflared" ''
          exec ${pkgs.unstable.cloudflared}/bin/cloudflared \
            --origincert ${config.sops.secrets.cloudflared_tunnel_crt.path} \
            --credentials-file ${config.sops.secrets.cloudflared_tunnel_auth_creds.path} \
            "$@"
        '')
      ];

      sops =
        let
          sopsConfig = {
            sopsFile = host.secretsFile;
            group = "wheel";
            mode = "0440";
          };
        in
        {
          secrets.cloudflared_tunnel_crt = sopsConfig;
          secrets.cloudflared_tunnel_auth_creds = sopsConfig;
        };

      boot.kernel.sysctl = {
        "net.core.rmem_max" = 7500000;
        "net.core.wmem_max" = 7500000;
      };

      networking.firewall.allowedUDPPorts = [ 7844 ];

      services.cloudflared = {
        enable = true;
        inherit package;
        certificateFile = config.sops.secrets.cloudflared_tunnel_crt.path;

        tunnels = {
          # cloudflared tunnel create {tunnelName}
          "${cfg.tunnelId}" = {
            credentialsFile = "${config.sops.secrets.cloudflared_tunnel_auth_creds.path}";

            # cloudflared tunnel route dns {cfg.tunnelId} {domain}
            ingress = { };

            default = "http_status:404";
          };
        };
      };

      systemd.services = mapAttrs' (
        name: _:
        nameValuePair "cloudflared-tunnel-${name}" {
          requires = [ "run-secrets.d.mount" ];
        }
      ) config.services.cloudflared.tunnels;
    };
}
