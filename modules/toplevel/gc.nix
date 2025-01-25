{ delib, ... }:

let
  inherit (delib) module;
in
module {
  name = "toplevel.gc";

  nixos.always = {
    nix = {
      settings = {
        auto-optimise-store = true;
        warn-dirty = false;
      };
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-old";
      };
    };

    boot.tmp.cleanOnBoot = true;
  };

  home.always = {
    news.display = "silent";
    nix.gc = {
      automatic = true;
      persistent = true;
      frequency = "weekly";
      options = "--delete-old";
    };
  };
}
