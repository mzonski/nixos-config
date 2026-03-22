{
  delib,
  pkgs,
  lib,
  ...
}:
let
  inherit (delib)
    module
    moduleOptions
    boolOption
    strOption
    intOption
    listOfOption
    int
    ;
  inherit (pkgs) writeShellScriptBin;
  inherit (lib) optionalString;
in
module {
  name = "programs.utils.mitmproxy";

  options = moduleOptions {
    enable = boolOption false;
    interface = strOption "eth0";
    port = intOption 8080;
    redirectPorts = listOfOption int [
      80
      443
    ];
  };

  nixos.ifEnabled =
    { cfg, ... }:
    let
      iptablesRules =
        variant:
        builtins.concatStringsSep "\n" (
          builtins.concatMap (dport: [
            "iptables -t nat ${
              if variant == "append" then "-A" else "-D"
            } PREROUTING -i ${cfg.interface} -p tcp --dport ${builtins.toString dport} -j REDIRECT --to-port ${builtins.toString cfg.port} ${
              optionalString (variant == "delete") "2>/dev/null || true"
            }"
            "ip6tables -t nat ${
              if variant == "append" then "-A" else "-D"
            } PREROUTING -i ${cfg.interface} -p tcp --dport ${builtins.toString dport} -j REDIRECT --to-port ${builtins.toString cfg.port} ${
              optionalString (variant == "delete") "2>/dev/null || true"
            }"
          ]) cfg.redirectPorts
        );

      turnOnScript = writeShellScriptBin "mitmproxy-on" ''
        echo "Enabling IP forwarding..."
        sysctl -w net.ipv4.ip_forward=1
        sysctl -w net.ipv6.conf.all.forwarding=1

        echo "Disabling ICMP redirects..."
        sysctl -w net.ipv4.conf.all.send_redirects=0

        echo "Setting up iptables rules on interface ${cfg.interface} -> port ${builtins.toString cfg.port}..."
        ${iptablesRules "append"}

        echo "Done. Start mitmproxy with:"
        echo "  mitmproxy --mode transparent --showhost --listen-port ${builtins.toString cfg.port}"
      '';

      turnOffScript = writeShellScriptBin "mitmproxy-off" ''
        echo "Removing iptables rules on interface ${cfg.interface} -> port ${builtins.toString cfg.port}..."
        ${iptablesRules "delete"}

        echo "Restoring sysctl defaults..."
        sysctl -w net.ipv4.ip_forward=0
        sysctl -w net.ipv6.conf.all.forwarding=0
        sysctl -w net.ipv4.conf.all.send_redirects=1

        echo "Transparent proxy disabled"
      '';
    in
    {
      environment.systemPackages = with pkgs.unstable; [
        mitmproxy
        turnOnScript
        turnOffScript
      ];

      networking.firewall.allowedTCPPorts = [ cfg.port ] ++ cfg.redirectPorts;
    };
}
