{ pkgs, lib }:
let
  inherit (lib.strings) concatMapStrings;
in
rec {
  getDriverInfo = pkgs.writeShellScript "get_driver_info" ''
    LSPCI_BIN="${pkgs.pciutils}/bin/lspci"

    get_driver_info() {
      local device_id="$1"
      local driver_info
          
      driver_info=$("$LSPCI_BIN" -nnk | grep -A3 "$device_id" | grep "Kernel driver in use" | cut -d: -f2 | xargs 2>/dev/null)
          
      if [[ -n "$driver_info" ]]; then
            echo "$driver_info"
      else
            echo "No driver loaded"
      fi
    }
  '';

  getPciIdFromDeviceId = pkgs.writeShellScript "get_pci_id_from_device_id" ''
    LSPCI_BIN="${pkgs.pciutils}/bin/lspci"
    AWK_BIN="${pkgs.gawk}/bin/awk"

    get_pci_id_from_device_id() {
      local device_id="$1"
      echo $("$LSPCI_BIN" -mmn -d "$device_id" | "$AWK_BIN" '{gsub(/[:".]/, "_", $1); print "pci_0000_" $1}')
    }
  '';

  checkGpuDriver =
    deviceIds:
    pkgs.writeShellScript "check_gpu_devices" ''
      source ${getDriverInfo}

      check_gpu_driver() {
        local expected_driver="$1"
        local driver_loaded=false
        
        ${concatMapStrings (deviceId: ''
          driver_info=$(get_driver_info "${deviceId}")
          if [[ "$driver_info" == "$expected_driver" ]]; then
            echo "Device ${deviceId} already using "$expected_driver" driver, skipping..."
            driver_loaded=true
          fi
        '') deviceIds}

        if [ "$driver_loaded" = true ]; then
          echo "$expected_driver drivers already attached, nothing to do"
          exit 0
        fi
      }
    '';
}
