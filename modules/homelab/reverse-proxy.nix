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
    isHomelabEnabled
    boolOption
    ;
  inherit (lib)
    mkIf
    mapAttrs'
    nameValuePair
    optionalAttrs
    ;
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
      requireAuth = boolOption true;
    };
  }) { };

  nixos.always =
    { myconfig, cfg, ... }:
    let
      homelabHostDomain = "${host.name}.${myconfig.homelab.domain}";
    in
    mkIf (isHomelabEnabled myconfig && cfg != { }) {
      assertions = [
        (assertEnabled myconfig "services.nginx.enable")
      ];

      security.acme.certs."${homelabHostDomain}" = {
        domain = homelabHostDomain;
        extraDomainNames = [ "*.${homelabHostDomain}" ];

      };

      services.nginx.virtualHosts = mapAttrs' (
        serviceName: options:
        let
          serverName = "${
            if options.subdomain != null then options.subdomain else serviceName
          }.${homelabHostDomain}";
        in
        nameValuePair serverName {
          forceSSL = true;
          useACMEHost = homelabHostDomain;

          locations = {
            "/" = {
              proxyPass = "${options.protocol}://${options.ip}:${toString options.port}/";
              proxyWebsockets = true;
              extraConfig = mkIf (myconfig.services.tinyauth.enable && options.protected) ''
                auth_request /tinyauth;
                error_page 401 = @tinyauth_login;
              '';
            };
          }
          // optionalAttrs (myconfig.services.tinyauth.enable && options.protected) {
            "/tinyauth" = {
              proxyPass = "http://127.0.0.1:${toString myconfig.services.tinyauth.port}/api/auth/nginx";
              extraConfig = ''
                internal;
                proxy_pass_request_body off;
                proxy_set_header Content-Length "";
                proxy_set_header X-Forwarded-Proto $scheme;
                proxy_set_header X-Forwarded-Host $http_host;
                proxy_set_header X-Forwarded-Uri $request_uri;
              '';
            };

            "@tinyauth_login" = {
              return = "302 ${myconfig.services.tinyauth.domain}/login?redirect_uri=$scheme://$http_host$request_uri";
            };
          };
        }
      ) cfg;
    };
}
