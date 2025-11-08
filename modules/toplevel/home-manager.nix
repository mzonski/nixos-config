{
  delib,
  moduleSystem,
  homeManagerUser,
  config,
  pkgs,
  ...
}:
delib.module {
  name = "home-manager";

  myconfig.always.args.shared.homeconfig =
    if moduleSystem == "home" then config else config.home-manager.users.${homeManagerUser};

  nixos.always = {
    environment.systemPackages = [ pkgs.home-manager ];
    home-manager = {
      backupFileExtension = "home_manager_backup";
      useUserPackages = true;
      useGlobalPkgs = true;
    };
  };

  home.always =
    let
      username = homeManagerUser;
    in
    {
      home = {
        inherit username;
        homeDirectory = "/home/${username}";
      };
    };
}
