# https://github.com/yunfachi/denix/blob/cbd8b8e09b64cedad7380a34abe8a3a4e332a561/lib/extensions/base/default.nix
{ delib, ... }:
delib.extension {
  name = "mybase";
  description = "Implement feature-rich and fine-tunable modules for hosts and rices with minimal effort";
  maintainers = with delib.maintainers; [ yunfachi ];

  initialConfig = {
    enableAll = true;

    args = {
      enable = false;
      path = "args";
    };

    assertions = {
      enable = true;
      moduleSystem = "home-manager";
    };
  };
}
