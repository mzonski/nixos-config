{
  delib,
  lib,
  homeManagerUser,
  ...
}:
let
  inherit (delib)
    module
    moduleOptions
    boolOption
    attrsOfOption
    submodule
    strOption
    intOption
    listOfOption
    package
    allowNull
    ;
  defaultInterval = 300;
in
module {
  name = "services.git-sync";

  options = moduleOptions {
    enable = boolOption false;
    defaultGitPath = strOption "/home/${homeManagerUser}/git";
    defaultRemote = strOption "ssh://gitea@git.tomato.local.zonni.pl:22";

    extraPackages = listOfOption package [ ];
    interval = intOption defaultInterval;

    repositories = attrsOfOption (submodule {
      options = {
        notInDefaultPath = boolOption false;
        notInDefaultRemote = boolOption false;
        interval = allowNull (intOption null);

        path = strOption "";
        uri = strOption "";
      };
    }) { };
  };

  home.ifEnabled =
    { cfg, ... }:
    let
      join = base: rel: "${lib.removeSuffix "/" base}/${lib.removePrefix "/" rel}";
    in
    {
      services.git-sync = {
        enable = true;
        repositories = lib.mapAttrs (_: repo: {
          path = if repo.notInDefaultPath then repo.path else join cfg.defaultGitPath repo.path;
          uri = if repo.notInDefaultRemote then repo.uri else join cfg.defaultRemote "${repo.uri}.git";
          interval = if repo.interval != null then repo.interval else cfg.interval;
          inherit (cfg) extraPackages;
        }) cfg.repositories;
      };
    };
}
