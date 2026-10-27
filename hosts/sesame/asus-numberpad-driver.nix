{ delib, inputs, ... }:
delib.host {
  name = "sesame";

  nixos = {
    imports = [
      inputs.nixZpkgs.nixosModules.asus-numberpad-driver
    ];

    systemd.services.asus-numberpad-driver = {
      after = [ "display-manager.service" ];

      serviceConfig.SyslogIdentifier = "asus-numberpad-driver";
    };

    hardware.asus-numberpad-driver = {
      enable = true;
      package = inputs.nixZpkgs.packages.asus-numberpad-driver;
      layout = "up5401ea";
      wayland = true;
    };
  };
}
