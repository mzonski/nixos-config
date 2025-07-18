{
  pkgs,
  delib,
  lib,
  ...
}:
let
  inherit (delib) module;

  bashColorsScript = import ../../../../lib/bash/colors.nix { inherit pkgs; };
  inherit (import ../../../../lib/bash/devices.nix { inherit pkgs lib; }) getDriverInfo;

  getDriverColor = pkgs.writeShellScript "get_driver_color" ''
    get_driver_color() {
        local driver="$1"
        case "$driver" in
            "amdgpu")
                text_red "$driver"
                ;;
            "nvidia")
                text_green "$driver"
                ;;
            "vfio-pci")
                text_cyan "$driver"
                ;;
            "snd_hda_intel")
                text_blue "$driver"
                ;;
            *)
                echo "$driver"
                ;;
    esac
    }
  '';

  makeScript =
    devices:
    pkgs.writeShellScriptBin "gpu-status" ''
      LSPCI_PATH="${pkgs.pciutils}/bin/lspci"

      source ${bashColorsScript}
      source ${getDriverInfo}
      source ${getDriverColor}

      declare -A DEVICES=(
          ["DGPU_VIDEO"]="${devices.dgpu-video}"
          ["DGPU_AUDIO"]="${devices.dgpu-audio}"
          ["IGD_VIDEO"]="${devices.igd-video}"
      )

      declare -A DEVICE_NAMES=(
          ["DGPU_VIDEO"]="DGPU VGA"
          ["DGPU_AUDIO"]="DGPU AUDIO"
          ["IGD_VIDEO"]="IGD VIDEO"
      )

      DEVICE_ORDER=("DGPU_VIDEO" "DGPU_AUDIO" "IGD_VIDEO")

      for device_type in "''${DEVICE_ORDER[@]}"; do
          device_id="''${DEVICES[$device_type]}"
          device_name="''${DEVICE_NAMES[$device_type]}"
          
          if "$LSPCI_PATH" -n -d "$device_id" | grep -q "$device_id"; then
              driver=$(get_driver_color "$(get_driver_info "$device_id")")
              echo -e "$device_name ($device_id): $driver"
          fi
      done
    '';
in
module {
  name = "features.virt-manager.vfio-passtrough";
  myconfig.ifEnabled =
    { cfg, ... }:
    {
      features.virt-manager.vfio-passtrough.scripts.gpu-status = makeScript cfg.devices;
    };
}
