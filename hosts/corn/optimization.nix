{ delib, ... }:
delib.host {
  name = "corn";

  nixos = {
    boot.kernel.sysctl."vm.swappiness" = 10;
  };
}
