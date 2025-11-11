{ delib, lib, ... }:
delib.extension {
  name = "custom-functions";
  description = "Extends Denix with custom functions";

  libExtension = _config: _final: prev: rec {
    assertEnabled' =
      config: pathStr: message:
      let
        pathList = lib.splitString "." pathStr;
        value = lib.attrByPath pathList false config;
        defaultMessage = "Configuration option '${pathStr}' must be enabled.";
      in
      {
        assertion = value;
        message = if message != null then message else defaultMessage;
      };

    assertEnabled = config: pathStr: assertEnabled' config pathStr null;

  };
}
