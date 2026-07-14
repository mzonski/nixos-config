{
  delib,
  pkgs,
  inputs,
  ...
}:
delib.module {
  name = "programs.utils.usbsniffer";

  options = delib.singleEnableOption false;

  nixos.always = {
    imports = [
      inputs.usb-sniffer.nixosModules.default
    ];
  };

  nixos.ifEnabled = {
    programs.usb-sniffer = {
      enable = true;
      wiresharkExtcap = true;
    };

    services.udev.packages = [
      (pkgs.writeTextDir "etc/udev/rules.d/40-usb-sniffer.rules" ''
        # Cheap USB Sniffer device access
        ATTRS{idVendor}=="6666", ATTRS{idProduct}=="6620", MODE="0666"
      '')
    ];
  };
}
