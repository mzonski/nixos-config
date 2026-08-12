{
  delib,
  pkgs,
  host,
  ...
}:
delib.module {
  name = "programs.desktop.mission-center";

  options = delib.singleEnableOption host.isDesktop;

  nixos.ifEnabled = {
    services.udev.packages = [
      (pkgs.writeTextDir "etc/udev/rules.d/99-powercap.rules" ''
        SUBSYSTEM=="powercap", KERNEL=="intel-rapl*", RUN+="${pkgs.coreutils}/bin/chmod a+r /sys/%p/energy_uj"
      '')
    ];

    security.wrappers.nethogs = {
      owner = "root";
      group = "root";
      capabilities = "cap_net_admin,cap_net_raw,cap_dac_read_search,cap_sys_ptrace+pe";
      source = "${pkgs.nethogs}/bin/nethogs";
    };
  };

  home.ifEnabled.home.packages = with pkgs; [
    unstable.mission-center
  ];
}
