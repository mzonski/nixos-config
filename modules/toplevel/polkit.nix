{ delib, ... }:
delib.module {
  name = "polkit";
  nixos.always = {
    security.polkit = {
      enable = true;
      extraConfig = ''
        polkit.addRule(function(action, subject) {
          var powerActions = [
            "org.freedesktop.login1.reboot",
            "org.freedesktop.login1.power-off",
            "org.freedesktop.login1.hibernate",
            "org.freedesktop.login1.halt"
          ];
          
          if (powerActions.indexOf(action.id) !== -1) {
            return polkit.Result.YES;
          }
        });
      '';
    };
  };
}
