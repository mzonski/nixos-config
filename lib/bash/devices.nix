{ pkgs, lib }:
let
  inherit (lib.strings) concatMapStrings;
  inherit (import ./utils.nix { inherit lib; })
    extendPath
    ;
in
rec {
  getDriverInfo = pkgs.writeShellScript "get_driver_info" ''
    ${extendPath ([
      pkgs.pciutils
    ])}

    get_driver_info() {
      local device_id="$1"
      local driver_info
          
      driver_info=$(lspci -nnk | grep -A3 "$device_id" | grep "Kernel driver in use" | cut -d: -f2 | xargs 2>/dev/null)
          
      if [[ -n "$driver_info" ]]; then
            echo "$driver_info"
      else
            echo "No driver loaded"
      fi
    }
  '';

  getPciIdFromDeviceId = pkgs.writeShellScript "get_pci_id_from_device_id" ''
    ${extendPath ([
      pkgs.pciutils
      pkgs.gawk
    ])}

    get_pci_id_from_device_id() {
      local device_id="$1"
      echo $(lspci -mmn -d "$device_id" | awk '{gsub(/[:".]/, "_", $1); print "pci_0000_" $1}')
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

  removeKernelModulesx = modules: ''
    remove_kernel_modules() {
      for module in "$@"; do
        echo "Removing module $module"
        rmmod "$module"
      done
    }

    remove_kernel_modules ${pkgs.lib.concatStringsSep " " modules}
  '';

  removeKernelModules =
    modules:
    concatMapStrings (moduleName: ''
      rmmod ${moduleName}
    '') modules;

  loadKernelModules =
    modules:
    concatMapStrings (moduleName: ''
      modprobe -i ${moduleName}
    '') modules;

  reattachDevices =
    deviceIds:
    ''
      source ${getPciIdFromDeviceId}
    ''
    + concatMapStrings (deviceId: ''
      virsh nodedev-reattach $(get_pci_id_from_device_id "${deviceId}")
      echo "Device ${deviceId} reattached to host"
    '') deviceIds;

}
