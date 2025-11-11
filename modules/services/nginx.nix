{ delib, config, ... }:
let
  inherit (delib) module singleEnableOption;
in
module {
  name = "services.nginx";

  options = singleEnableOption false;

  nixos.ifEnabled =
    { myconfig, cfg, ... }:
    {
      sops = {
        secrets.cloudflare_api_token_zonni_pl = { };
        templates.acme-config = {
          content = ''
            CLOUDFLARE_DNS_API_TOKEN=${config.sops.placeholder.cloudflare_api_token_zonni_pl}
          '';

          owner = "acme";
          group = "root";
        };
      };

      security.acme = {
        acceptTerms = true;
        defaults = {
          email = "me@zonni.pl";
          dnsProvider = "cloudflare";
          credentialsFile = config.sops.templates.acme-config.path;
        };
      };

      networking = {
        firewall.allowedTCPPorts = [
          80
          443
        ];
      };

      users.users.nginx.extraGroups = [ "acme" ];

      services.nginx = {
        enable = true;
      };
    };
}
