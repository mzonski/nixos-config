{
  delib,
  lib,
  host,
  ...
}:
let
  inherit (delib)
    module
    attrsOfOption
    submodule
    enumOption
    strOption
    noDefault
    assertEnabled
    allowNull
    intOption
    ;
  inherit (lib) mkIf mapAttrs' nameValuePair;
  inherit (builtins) toString;
in
module {
  name = "homelab.reverse-proxy";

  options.homelab.reverse-proxy = attrsOfOption (submodule {
    options = {
      ip = strOption "127.0.0.1";
      protocol = enumOption [ "http" "https" ] "http";
      subdomain = allowNull (strOption null);
      port = noDefault (intOption null);
    };
  }) { };

  nixos.always =
    { myconfig, cfg, ... }:
    let
      homelabHostDomain = "${host.name}.${myconfig.homelab.domain}";
    in
    mkIf (cfg != { }) {
      assertions = [
        (assertEnabled myconfig "services.nginx.enable")
      ];

      security.acme.certs."${homelabHostDomain}" = {
        domain = homelabHostDomain;
        extraDomainNames = [ "*.${homelabHostDomain}" ];

      };

      services.nginx.virtualHosts = mapAttrs' (
        serviceName: options:
        nameValuePair
          "${if options.subdomain != null then options.subdomain else serviceName}.${homelabHostDomain}"
          {
            forceSSL = true;
            useACMEHost = homelabHostDomain;

            locations."/" = {
              proxyPass = "${options.protocol}://${options.ip}:${toString options.port}/";
              proxyWebsockets = true;
            };
          }
      ) cfg;
    };
}
