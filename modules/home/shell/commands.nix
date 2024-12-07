{
  lib,
  pkgs,
  mylib,
  ...
}:

with lib;
with mylib;
{
  options.commands = {
    runTerminal = mkStrOpt "${pkgs.kitty}/bin/kitty";
  };
}
