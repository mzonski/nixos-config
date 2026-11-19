{ delib, pkgs, ... }:
let
  inherit (delib) singleEnableOption module;
in
module {
  name = "features.ai";

  options = singleEnableOption false;

  nixos.ifEnabled = {
    services.ollama = {
      enable = false;
      package = pkgs.unstable.ollama-cuda;
    };

    services.open-webui = {
      enable = false;
      port = 8081;
    };

    environment.systemPackages =
      with pkgs;
      [
        #alpaca
        mcp-nixos
        local.mcp-grafana
        playwright-mcp
      ]
      ++ (with pkgs.unstable; [
        mcp-server-git
      ]);

    environment.variables =
      let
        prlimit = "${pkgs.util-linux}/bin/prlimit";
      in
      {
        REA_ADB_PATH = "${pkgs.android-tools}/bin/adb";
        REA_APKTOOL_COMMAND = "${pkgs.apktool}/bin/apktool";

        REA_GDB_COMMAND = "${pkgs.gdb}/bin/gdb";
        REA_OBJDUMP_COMMAND = "${pkgs.binutils}/bin/objdump";
        REA_RIZIN_COMMAND = "${pkgs.rizin}/bin/rizin";
        REA_PWNTOOLS_PYTHON = "${pkgs.python3.withPackages (ps: [ ps.pwntools ])}/bin/python";

        GHIDRA_INSTALL_DIR = "${pkgs.ghidra}/lib/ghidra";
        JAVA_HOME = "${pkgs.jdk21.home}";

        REA_ILSPY_CMD_PATH = "${pkgs.ilspycmd}/bin/ilspycmd";

        REA_BINWALK_COMMAND = "${pkgs.binwalk}/bin/binwalk";
        REA_UNBLOB_COMMAND = "${pkgs.unstable.unblob}/bin/unblob"; # REA pins 26.6.4, nixpkgs has 26.3.30
        REA_FIRMWARE_PRLIMIT_COMMAND = prlimit;

        REA_TSHARK_COMMAND = "${pkgs.wireshark-cli}/bin/tshark";
        REA_CAPINFOS_COMMAND = "${pkgs.wireshark-cli}/bin/capinfos";
        REA_TSHARK_PRLIMIT_COMMAND = prlimit;
        REA_MITMDUMP_COMMAND = "${pkgs.mitmproxy}/bin/mitmdump";

        REA_SIGROK_COMMAND = "${pkgs.sigrok-cli}/bin/sigrok-cli";
        REA_SIGROK_PRLIMIT_COMMAND = prlimit;
        REA_WABT_BIN_DIRECTORY = "${pkgs.wabt}/bin";
        REA_EVM_PRLIMIT_COMMAND = prlimit;
        REA_JAVASCRIPT_PRLIMIT_COMMAND = prlimit;

        REA_BROWSER_EXECUTABLE = "${pkgs.chromium}/bin/chromium";
      };
  };
}
