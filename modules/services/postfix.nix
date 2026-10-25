{
  delib,
  host,
  config,
  ...
}:
let
  inherit (delib)
    module
    moduleOptions
    boolOption
    ;
  serviceName = "postfix";
in
module {
  name = "services.${serviceName}";

  options = moduleOptions {
    enable = boolOption false;
  };

  myconfig.ifEnabled = {
    user.groups = [ serviceName ];
  };

  nixos.ifEnabled = {
    sops =
      let
        sopsConfig = {
          sopsFile = host.secretsFile;
          owner = serviceName;
          group = serviceName;
        };
        placeholder = config.sops.placeholder;
      in
      {
        secrets.postfix_relay_host = sopsConfig;
        secrets.postfix_sender_address = sopsConfig;
        secrets.postfix_sender_password = sopsConfig;

        templates = {
          postfix_sasl_passwd = {
            inherit (sopsConfig) owner group;
            content = "${placeholder.postfix_relay_host} ${placeholder.postfix_sender_address}:${placeholder.postfix_sender_password}\n";
          };
          postfix_transport = {
            inherit (sopsConfig) owner group;
            content = "/.*/ smtp:${placeholder.postfix_relay_host}\n";
          };
          postfix_sender_canonical = {
            inherit (sopsConfig) owner group;
            content = "/.+/ ${placeholder.postfix_sender_address}\n";
          };
        };
      };

    services.postfix = {
      enable = true;
      settings.main =
        let
          templates = config.sops.templates;
        in
        {
          myhostname = "${host.name}.local";
          inet_interfaces = "loopback-only";
          mydestination = "";

          transport_maps = "regexp:${templates.postfix_transport.path}";
          sender_canonical_maps = "regexp:${templates.postfix_sender_canonical.path}";

          smtp_tls_security_level = "encrypt";
          smtp_sasl_auth_enable = "yes";
          smtp_sasl_security_options = "noanonymous";
          smtp_sasl_password_maps = "texthash:${templates.postfix_sasl_passwd.path}";
        };
    };
  };
}
