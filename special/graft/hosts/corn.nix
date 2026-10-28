{ delib, lib, ... }:
let
  inherit (lib) mkForce;
in
delib.host {
  name = "corn";

  myconfig = {
    features = {
      virt-manager.enable = mkForce false;
      gaming.enable = mkForce false;
      ai.enable = mkForce false;
      camera.enable = mkForce false;
      docker.enable = mkForce false;
      general-development.enable = mkForce true;
      quietboot.enable = mkForce false;
      zfs.enable = mkForce false;
    };

    programs = {
      jetbrains.enable = mkForce false;
      desktop.obs.enable = mkForce false;
      desktop.libreoffice.enable = mkForce false;
    };
  };
}
