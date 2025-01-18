{ system, ... }:

{
  mkPkgs =
    pkgs: overlays:
    import pkgs {
      inherit system;
      config.allowUnfree = true;
      config.permittedInsecurePackages = [
        "archiver-3.5.1"
      ];
      overlays = overlays;
    };
}
