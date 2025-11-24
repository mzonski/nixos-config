{
  delib,
  inputs,
  ...
}:
delib.host {
  name = "sesame";

  nixos = {
    imports = [
      inputs.asus-numberpad-driver.nixosModules.default
    ];

    systemd.services.asus-numberpad-driver.serviceConfig.SyslogIdentifier = "asus-numberpad-driver";

    services.asus-numberpad-driver = {
      enable = true;
      layout = "up5401ea";
      wayland = true;
      runtimeDir = "/run/user/1000/";
      waylandDisplay = "wayland-0";
      ignoreWaylandDisplayEnv = false;
    };
  };
}
