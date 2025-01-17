{ lib, ... }:

let
  inherit (builtins) substring stringLength;
  inherit (lib.strings) toUpper;
in
{
  capitalize =
    str:
    let
      head = substring 0 1 str;
      tail = substring 1 (stringLength str) str;
    in
    (toUpper head) + tail;
}
