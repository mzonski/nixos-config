{ delib, pkgs, ... }:

let
  inherit (delib) module;
in
module {
  name = "programs.wayland";

  home.ifEnabled = {
    services.cliphist = {
      enable = true;
      package = pkgs.cliphist;
      allowImages = true;
      # extraOptions = [
      #   "--max-items 100"
      #   "--primary"
      # ];
    };

    systemd.user.services.cliphist-watch = {
      Unit = {
        Description = "Clipboard history watcher for cliphist";
        PartOf = [ "graphical-session.target" ];
        After = [
          "graphical-session.target"
          "cliphist.service"
        ];
        Requires = [ "cliphist.service" ];
      };

      Service = {
        ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store";
        Restart = "always";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    home.packages = with pkgs; [
      wl-clipboard
      local.nwg-clipman
    ];
  };
}
