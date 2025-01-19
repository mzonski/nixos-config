{ lib, ... }:

let
  inherit (lib) mkOption types;
in
{
  mkOpt = type: default: mkOption { inherit type default; };

  mkOpt' =
    type: default: description:
    mkOption { inherit type default description; };

  mkBoolOpt =
    default:
    mkOption {
      inherit default;
      type = types.bool;
      example = true;
    };

  mkBoolOpt' =
    default: description:
    mkOption {
      inherit default description;
      type = types.bool;
      example = true;
    };

  mkStrOpt =
    default:
    mkOption {
      inherit default;
      type = types.str;
      description = "This is a string option";
    };

  mkStrOpt' =
    default: description:
    mkOption {
      inherit default description;
      type = types.str;
    };

  mkNumOpt =
    default:
    mkOption {
      inherit default;
      type = types.number;
      description = "This is a number option";
    };

  mkNumOpt' =
    default: description:
    mkOption {
      inherit default description;
      type = types.number;
    };

  mkEnumOpt =
    enum: default:
    mkOption {
      inherit default;
      type = types.nullOr (types.enum enum);
      example = builtins.head enum;
    };

  mkEnumOpt' =
    enum: default: description:
    mkOption {
      inherit default description;
      type = types.nullOr (types.enum enum);
      example = builtins.head enum;
    };

}
