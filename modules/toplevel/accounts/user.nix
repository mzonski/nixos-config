{
  delib,
  lib,
  homeManagerUser,
  ...
}:
let
  inherit (delib) listOfOption attrsOption str;
  inherit (lib)
    types
    mkOption
    concatStringsSep
    concatMapStringsSep
    mapAttrsToList
    mapAttrs
    isList
    ;
in
delib.module {
  name = "user";

  options = {
    user = {
      groups = listOfOption str [ ];
      config = attrsOption { };
      env = mkOption {
        type = types.attrsOf (
          types.oneOf [
            types.str
            types.path
            (types.listOf (types.either types.str types.path))
          ]
        );
        apply = mapAttrs (
          n: v: if isList v then concatMapStringsSep ":" (x: toString x) v else (toString v)
        );
        default = { };
        description = "Environment variables to be set";
      };
    };
  };

  myconfig.always =
    { cfg, ... }:
    {
      user.groups = [ "users" ];
      user.config = {
        name = homeManagerUser;
        createHome = true;
        isNormalUser = true;
        uid = 1000;
        group = homeManagerUser;
        home = "/home/${homeManagerUser}";
        extraGroups = cfg.groups;
        initialPassword = homeManagerUser;
      };

      # must already begin with pre-existing PATH. Also, can't use binDir here,
      # because it contains a nix store path.
      user.env.PATH = [
        "$XDG_BIN_HOME"
        "$PATH"
      ];
    };

  nixos.always =
    { cfg, ... }:
    let
      inherit (cfg) config env;
    in
    {
      users.mutableUsers = true;
      users.users.${config.name} = config;
      users.groups.${config.name} = { };

      environment.extraInit = concatStringsSep "\n" (mapAttrsToList (n: v: "export ${n}=\"${v}\"") env);
    };
}
