{ lib, mylib, ... }:
with lib;
with mylib;
{
  options.my.nixGL = with types; {
    enable = mkBoolOpt false;
  };
}
