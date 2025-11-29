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
    any
    attrValues
    filterAttrs
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
      root = boolOption false;
      public = boolOption false;
    };
  }) { };

  nixos.always =
    { myconfig, cfg, ... }:
    let
      tinyAuthCfg = myconfig.services.tinyauth;
      cloudflaredCfg = myconfig.services.cloudflared;
      homelabHostDomain = "${host.name}.${myconfig.homelab.domain}";
      inherit (myconfig.homelab) rootDomain;

      publicServices = filterAttrs (serviceName: options: options.root && options.public) cfg;
      getDomain =
        domain: serviceName: options:
        "${if options.subdomain != null then options.subdomain else serviceName}.${domain}";
      getUpstreamUrl = options: "${options.protocol}://${options.ip}:${toString options.port}";
    in
    mkIf (isHomelabEnabled myconfig && cfg != { }) {
      assertions = [
        (assertEnabled myconfig "services.nginx.enable")
      ];

      security.acme.certs = {
        "${homelabHostDomain}" = {
          domain = homelabHostDomain;
          extraDomainNames = [ "*.${homelabHostDomain}" ];
        };
      }
      // optionalAttrs (any (options: options.root) (attrValues cfg)) {
        "${rootDomain}" = {
          domain = "${rootDomain}";
          extraDomainNames = [ "*.${rootDomain}" ];
        };
      };

      services.cloudflared.tunnels = mkIf cloudflaredCfg.enable {
        "${cloudflaredCfg.tunnelId}" = {
          ingress = mapAttrs' (
            serviceName: options:
            nameValuePair (getDomain rootDomain serviceName options) (getUpstreamUrl options)
          ) publicServices;
        };
      };

      services.nginx.virtualHosts = mapAttrs' (
        serviceName: options:
        let
          hostDomain = if options.root then "${rootDomain}" else "${homelabHostDomain}";
          isTinyauthEnabled = tinyAuthCfg.enable && options.requireAuth;
        in
        nameValuePair (getDomain hostDomain serviceName options) {
          forceSSL = true;
          useACMEHost = hostDomain;

          locations = {
            "/" = {
              proxyPass = "${(getUpstreamUrl options)}/";
              proxyWebsockets = true;
              extraConfig = mkIf isTinyauthEnabled ''
                auth_request /tinyauth;
                error_page 401 = @tinyauth_login;
              '';
            };
          }
          // optionalAttrs isTinyauthEnabled {
            "/tinyauth" = {
              proxyPass = "http://127.0.0.1:${toString tinyAuthCfg.port}/api/auth/nginx";
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
              return = "302 ${tinyAuthCfg.domain}/login?redirect_uri=$scheme://$http_host$request_uri";
            };
          };
        }
      ) cfg;
    };
}
