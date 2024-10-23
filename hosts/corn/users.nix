{ ... }:

{
  users.users = {
    zonni = {
      isNormalUser = true;
      description = "Zonni";
      extraGroups = [
        "networkmanager"
        "wheel"
        "audio"
      ];
      #openssh.authorizedKeys.keys = [
      # TODO: Add SSH public key(s) here, if you plan on using SSH to connect
      #];
    };
  };
}
