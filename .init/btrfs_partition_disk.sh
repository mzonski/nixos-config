#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o xtrace

# Script purpose: Install NixOS on BTRFS with advanced subvolume layout.
# Intended to be run from a booted NixOS minimal ISO image, as root.

[[ $UID -eq 0 && $EUID -eq 0 && $USER == root ]]

case "${1:-}" in
    ("partition") ACTION="partition" ;;
    ("unmount") ACTION="unmount" ;;
    ("verify") ACTION="verify" ;;
    ("mount") ACTION="mount" ;;
    (*) echo "Usage: $0 {partition|unmount|verify|mount}" && exit 1 ;;
esac

INST_NAME=corn
DRIVES=(
    /dev/disk/by-id/ata-CT480BX500SSD1_2030E408A798
)

declare -A PARITION_TYPE=(
    [ESI]="C12A7328-F81F-11D2-BA4B-00A0C93EC93B"
    [FS]="0FC63DAF-8483-4772-8E79-3D69D8477DE4"
    [SWAP]="0657FD6D-A4AB-43C4-84E5-0933C84B4F4F"
)

# Define partition configurations in a single data structure
declare -A PARTITIONS=(
    [ESI]="number=1;type=${PARITION_TYPE[ESI]};extent=1M:+1G;opts="
    [root]="number=2;type=${PARITION_TYPE[FS]};extent=0:0;opts="
    [swap]="number=3;type=${PARITION_TYPE[SWAP]};extent=-32G:0;opts="
)

# Order of operations
PARTITION_OP_ORDER=( ESI swap root )

# Default mount options for BTRFS
DEFAULT_MOUNT_OPTS="compress=zstd:1,noatime,space_cache=v2,discard=async"

# Define subvolume configurations in a single data structure
declare -A SUBVOLUMES=(
    [@]="mountpoint=/;opts=$DEFAULT_MOUNT_OPTS,ssd,commit=120,subvol=root"
    [@home]="mountpoint=/home;opts=$DEFAULT_MOUNT_OPTS,ssd,subvol=home"
    [@nix]="mountpoint=/nix;opts=$DEFAULT_MOUNT_OPTS,nodev,nosuid,subvol=nix"
    [@persist]="mountpoint=/persist;opts=$DEFAULT_MOUNT_OPTS,ssd,subvol=persist"
#    [@var]="mountpoint=/var;opts=$DEFAULT_MOUNT_OPTS,nodev,nosuid,subvol=var"
#    [@var/log]="mountpoint=/var/log;opts=$DEFAULT_MOUNT_OPTS,nodev,nosuid,noexec,subvol=var/log"
)

# Function to get partition attribute
get_partition_attr() {
    local part=$1 attr=$2
    local config=${PARTITIONS[$part]}
    echo "$config" | grep -o "$attr=[^;]*" | cut -d= -f2
}

# Function to get subvolume attribute
get_subvolume_attr() {
    local subvol=$1 attr=$2
    local config=${SUBVOLUMES[$subvol]}
    echo "$config" | grep -o "$attr=[^;]*" | cut -d= -f2
}

# Function to wait until partitions are either present or absent
wait-until-partitions() {
    local MODE=$1 STATE D
    sleep 1
    partprobe ${DRIVES[@]}
    sleep 1
    
    while true; do
        for D in ${DRIVES[@]}; do
            for part in "${!PARTITIONS[@]}"; do
                local number=$(get_partition_attr "$part" "number")
                if [ -b $D-part$number ]; then
                    STATE=present
                else
                    STATE=absent
                fi
                if [ $STATE != $MODE ]; then
                    sleep 1
                    continue 3
                fi
            done
        done
        break
    done
}

zap-discard-drives() {
    local D
    for D in ${DRIVES[@]}; do
        sgdisk --zap-all $D
        blkdiscard -v $D || echo "Proceeding without doing blkdiscard"
    done
    wait-until-partitions absent
}

partition-drives() {
    for part in ${PARTITION_OP_ORDER[@]}; do
        local number=$(get_partition_attr "$part" "number")
        local type=$(get_partition_attr "$part" "type")
        local extent=$(get_partition_attr "$part" "extent")
        local opts=$(get_partition_attr "$part" "opts")
        
        sgdisk $opts --new="$number:$extent" --typecode="$number:$type" --change-name="$number:$part"  ${DRIVES[0]} || {
            echo "Failed to create partition $part"
            return 1
        }
    done
    wait-until-partitions present
}


mount-all() {
    unmount-all
    local ROOT_PART="${DRIVES[0]}-part$(get_partition_attr "root" "number")"
    
    # Mount root subvolume
    if ! mount -o "subvol=@,$(get_subvolume_attr "@" "opts")" "$ROOT_PART" /mnt; then
        echo "Failed to mount root subvolume"
        exit 1
    fi
    
    # Create necessary mount points and persist directory structure
    mkdir -p /mnt/{home,nix,persist,boot,tmp}
    #mkdir -p /mnt/persist/{etc/nixos,var/lib}
    
    # Mount all subvolumes (except @ which is already mounted)
    for subvol in "${!SUBVOLUMES[@]}"; do
        [[ $subvol == "@" ]] && continue
        local mountpoint=$(get_subvolume_attr "$subvol" "mountpoint")
        local opts=$(get_subvolume_attr "$subvol" "opts")
        
        if ! mount -o "subvol=$subvol,$opts" "$ROOT_PART" "/mnt$mountpoint"; then
            echo "Failed to mount $subvol to /mnt$mountpoint"
            unmount-all
            exit 1
        fi
    done
    
    # Mount ESI partition
    if ! mount "${DRIVES[0]}-part$(get_partition_attr "ESI" "number")" /mnt/boot; then
        echo "Failed to mount ESI partition"
        unmount-all
        exit 1
    fi
    
    # Enable swap
    if ! swapon "${DRIVES[0]}-part$(get_partition_attr "swap" "number")"; then
        echo "Failed to enable swap"
        unmount-all
        exit 1
    fi
}

setup-filesystems() {
    local esi_number=$(get_partition_attr "ESI" "number")
    local swap_number=$(get_partition_attr "swap" "number")
    local root_number=$(get_partition_attr "root" "number")
    
    mkfs.fat -F 32 -n "boot" "${DRIVES[0]}-part${esi_number}"
    mkswap -L "swap" "${DRIVES[0]}-part${swap_number}"
    mkfs.btrfs -f -L "root" \
        --checksum xxhash \
        --metadata dup \
        --data single \
        -O no-holes \
        -R free-space-tree \
        "${DRIVES[0]}-part${root_number}"
}

create-subvolumes() {
    local ROOT_PART="${DRIVES[0]}-part$(get_partition_attr "root" "number")"
    
    # Mount BTRFS root temporarily
    if ! mount -o ${DEFAULT_MOUNT_OPTS} "$ROOT_PART" /mnt; then
        echo "Failed to mount root partition"
        exit 1
    fi
    
    # Create all subvolumes
    for subvol in "${!SUBVOLUMES[@]}"; do
        if ! btrfs subvolume create "/mnt/$subvol"; then
            echo "Failed to create subvolume $subvol"
            unmount-all
            exit 1
        fi
    done
    
    unmount-all
}

unmount-all() {
    # Disable swap first
    swapoff "${DRIVES[0]}-part$(get_partition_attr "swap" "number")" 2>/dev/null || true
    
    # Unmount all mountpoints in reverse order
    for subvol in "${!SUBVOLUMES[@]}"; do
        local mountpoint=$(get_subvolume_attr "$subvol" "mountpoint")
        [[ $mountpoint == "/" ]] && continue
        umount "/mnt$mountpoint" 2>/dev/null || true
    done
    
    # Unmount boot and root last
    umount "/mnt/boot" 2>/dev/null || true
    umount "/mnt" 2>/dev/null || true
    
    # Final check
    if mountpoint -q /mnt; then
        umount -R /mnt 2>/dev/null || true
    fi
}

create-btrfs() {
    zap-discard-drives
    partition-drives
    setup-filesystems
    create-subvolumes
}

verify-setup-old() {
    local status=0
    local ROOT_PART="${DRIVES[0]}-part$(get_partition_attr "root" "number")"
    
    echo "Starting system setup verification..."
    
    # 1. Verify partitions exist and have correct types
    echo "Checking partitions..."
    for part in ${!PARTITIONS[@]}; do
        local number=$(get_partition_attr "$part" "number")
        local type=$(get_partition_attr "$part" "type")
        local part_path="${DRIVES[0]}-part${number}"
        
        if ! [ -b "$part_path" ]; then
            echo "❌ Partition $part ($part_path) does not exist"
            status=1
            continue
        fi
        
        local current_type=$(sgdisk -i "$number" "${DRIVES[0]}" | grep "Partition GUID code:" | awk '{print toupper($4)}')
        if [ "$current_type" != "$type" ]; then
            echo "❌ Partition $part has incorrect type: expected $type, got $current_type"
            status=1
        else
            echo "✓ Partition $part exists and has correct type"
        fi
    done
    
    # 2. Verify filesystems
    echo -e "\nChecking filesystems..."
    
    # Check ESI filesystem
    local esi_part="${DRIVES[0]}-part$(get_partition_attr "ESI" "number")"
    if ! blkid "$esi_part" | grep -q "TYPE=\"vfat\""; then
        echo "❌ ESI partition does not have FAT filesystem"
        status=1
    else
        echo "✓ ESI partition has correct filesystem"
    fi
    
    # Check swap
    local swap_part="${DRIVES[0]}-part$(get_partition_attr "swap" "number")"
    if ! blkid "$swap_part" | grep -q "TYPE=\"swap\""; then
        echo "❌ Swap partition is not formatted as swap"
        status=1
    else
        echo "✓ Swap partition is correctly formatted"
    fi
    
    # Check BTRFS root
    if ! blkid "$ROOT_PART" | grep -q "TYPE=\"btrfs\""; then
        echo "❌ Root partition is not formatted as BTRFS"
        status=1
    else
        echo "✓ Root partition has correct filesystem"
    fi
    
    # 3. Verify BTRFS subvolumes and mount options
    echo -e "\nChecking BTRFS subvolumes and mount options..."
    
    # Temporarily mount root if not mounted
    local temp_mounted=false
    if ! mountpoint -q /mnt; then
        if ! mount -o ${DEFAULT_MOUNT_OPTS} "$ROOT_PART" /mnt; then
            echo "❌ Cannot mount root partition for verification"
            return 1
        fi
        temp_mounted=true
    fi
    
    # Check subvolumes exist
    for subvol in "${!SUBVOLUMES[@]}"; do
        if ! btrfs subvolume list /mnt | grep -q "$subvol"; then
            echo "❌ Subvolume $subvol does not exist"
            status=1
        else
            echo "✓ Subvolume $subvol exists"
        fi
    done
    
    # Clean up temporary mount
    if [ "$temp_mounted" = true ]; then
        umount /mnt
    fi
    
    # 4. Verify mount options
    echo -e "\nChecking mount options..."
    while read -r line; do
        local device=$(echo "$line" | awk '{print $1}')
        local mountpoint=$(echo "$line" | awk '{print $2}')
        local fstype=$(echo "$line" | awk '{print $3}')
        local options=$(echo "$line" | awk '{print $4}')
        
        # Skip non-relevant mounts
        if ! echo "$device" | grep -q "^${DRIVES[0]}"; then
            continue
        fi
        
        # Remove /mnt from mountpoint for comparison
        local relative_mountpoint=${mountpoint#/mnt}
        [ "$relative_mountpoint" = "" ] && relative_mountpoint="/"
        
        # Find matching subvolume
        local found=false
        for subvol in "${!SUBVOLUMES[@]}"; do
            local expected_mountpoint=$(get_subvolume_attr "$subvol" "mountpoint")
            if [ "$expected_mountpoint" = "$relative_mountpoint" ]; then
                found=true
                local expected_opts=$(get_subvolume_attr "$subvol" "opts")
                
                # Check if all expected options are present
                local missing_opts=false
                IFS=',' read -ra EXPECTED <<< "$expected_opts"
                for opt in "${EXPECTED[@]}"; do
                    if ! echo "$options" | grep -q "$opt"; then
                        echo "❌ Mount $mountpoint missing option: $opt"
                        missing_opts=true
                        status=1
                    fi
                done
                
                [ "$missing_opts" = false ] && echo "✓ Mount $mountpoint has correct options"
                break
            fi
        done
        
        [ "$found" = false ] && echo "⚠️ Found unexpected mount: $mountpoint"
        
    done < /proc/mounts

    # Final status
    echo -e "\nVerification complete!"
    if [ $status -eq 0 ]; then
        echo "✅ All checks passed successfully"
    else
        echo "❌ Some checks failed - see above for details"
    fi
    
    return $status
}



case "$ACTION" in
    "partition")
        create-btrfs
        echo "BTRFS partitioning completed successfully!"
        ;;
    "unmount")
        unmount-all
        echo "Unmount completed successfully!"
        ;;
    "mount")
        mount-all
        echo "Mounted at /mnt and ready for system installation."
        ;;
    "verify")
        verify-setup-old
        ;;
    *)
        echo "Usage: $0 {partition|unmount|verify}"
        exit 1
        ;;
esac
