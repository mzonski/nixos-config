{ delib, ... }:
let
  inherit (delib) module;
in
module {
  name = "programs.wayland";

  home.ifEnabled =
    { cfg, ... }:
    let
      primaryOut = cfg.hyprland.monitors.primary.output;
      secondaryOut = cfg.hyprland.monitors.secondary.output;
    in
    {
      wayland.windowManager.hyprland.settings.workspace = [
        "1, monitor:${primaryOut}, name:desktop, default:true, persistent:true"
        "2, monitor:${primaryOut}, name:browser, persistent:true"
        "3, monitor:${primaryOut}, name:terminal, persistent:true"
        "4, monitor:${primaryOut}, name:code, persistent:true"
        "5, monitor:${secondaryOut}, default:true, persistent:true"
      ];
    };
}
