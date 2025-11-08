{
  delib,
  config,
  pkgs,
  ...
}:
delib.module {
  name = "networking.topology";

  nixos.always =
    { cfg, ... }:
    {
      sops = {
        secrets = {
          ip_corn = { };
          ip_sesame = { };
          ip_tomato = { };
          ip_seed = { };
        };
        templates.hosts-home = {
          content = ''
            ${config.sops.placeholder.ip_corn} corn
            ${config.sops.placeholder.ip_sesame} sesame
            ${config.sops.placeholder.ip_tomato} tomato
            ${config.sops.placeholder.ip_seed} seed
          '';
          path = "/etc/hosts.home";
        };
      };

      system.activationScripts.sops-hosts = {
        text = "${
          (pkgs.writeScript "home-hosts-recreate" ''
            ${pkgs.gnused}/bin/sed -i '/# BEGIN HOME HOSTS/,/# END HOME HOSTS/d' /etc/hosts

            echo "# BEGIN HOME HOSTS" >> /etc/hosts
            cat ${config.sops.templates.hosts-home.path} >> /etc/hosts
            echo "# END HOME HOSTS" >> /etc/hosts
          '')
        }";
        deps = [ "setupSecrets" ];
      };
    };
}
