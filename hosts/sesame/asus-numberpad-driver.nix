{ delib, inputs, ... }:
delib.host {
  name = "sesame";

  nixos = {
    imports = [
      inputs.asus-numberpad-driver.nixosModules.default
    ];

    systemd.services.asus-numberpad-driver = {
      after = [ "display-manager.service" ];

      serviceConfig.SyslogIdentifier = "asus-numberpad-driver";
    };

    services.asus-numberpad-driver = {
      enable = true;
      layout = "up5401ea";
      wayland = true;
    };
  };
}
