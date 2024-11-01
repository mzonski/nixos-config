{

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/fa4ed866-9bcd-48e5-a57d-c34e1af3f3b7";
    fsType = "btrfs";
    options = [ "subvol=@" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/fa4ed866-9bcd-48e5-a57d-c34e1af3f3b7";
    fsType = "btrfs";
    options = [ "subvol=@home" ];
  };

  fileSystems."/persist" = {
    device = "/dev/disk/by-uuid/fa4ed866-9bcd-48e5-a57d-c34e1af3f3b7";
    fsType = "btrfs";
    options = [ "subvol=@persist" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/fa4ed866-9bcd-48e5-a57d-c34e1af3f3b7";
    fsType = "btrfs";
    options = [ "subvol=@nix" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/E449-D70F";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/d19a44bd-9e47-4957-83ac-b8e166da9184"; }
  ];

}
