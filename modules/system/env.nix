{
  config,
  options,
  lib,
  lib',
  pkgs,
  ...
}:

with lib;
with lib';
{
  options.host = with types; {
    env = mkOption {
      type = attrsOf (oneOf [
        str
        path
        (listOf (either str path))
      ]);
      apply = mapAttrs (
        n: v: if isList v then concatMapStringsSep ":" (x: toString x) v else (toString v)
      );
      default = { };
      description = "Environment variables to be set";
    };
  };

  config = {
    # must already begin with pre-existing PATH. Also, can't use binDir here,
    # because it contains a nix store path.
    host.env.PATH = [
      "$XDG_BIN_HOME"
      "$PATH"
    ];

    environment.extraInit = concatStringsSep "\n" (
      mapAttrsToList (n: v: "export ${n}=\"${v}\"") config.host.env
    );
  };
}
