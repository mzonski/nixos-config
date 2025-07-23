################################################
# Supported commands:
# home-manager build --flake .#zonni@corn
# home-manager switch --flake .#zonni@corn
# 
# sudo nixos-rebuild switch --flake .#corn
# nix flake update
################################################

FLAKE := .
USERNAME := $(shell whoami)
HOSTNAME := $(shell hostname)

.PHONY: all home system update

all: home system

update:
	@echo "Updating flake inputs..."
	nix flake update

clean:
	@echo "Cleaning old generations..."
	sudo ./utils/clear-nix-profiles.sh remove
	nix-collect-garbage --delete-old
	nix-store --gc --print-roots | egrep -v "^(/nix/var|/run/\w+-system|\{memory|/proc)"

home:
	@echo "Switching home-manager configuration..."
	home-manager build --flake $(FLAKE)#$(USERNAME)@$(HOSTNAME)
	home-manager switch --flake $(FLAKE)#$(USERNAME)@$(HOSTNAME)

system:
	@echo "Switching NixOS configuration..."
	sudo nixos-rebuild switch --flake $(FLAKE)#$(HOSTNAME)

sysboot:
	@echo "Switching NixOS configuration..."
	sudo nixos-rebuild boot --flake $(FLAKE)#$(HOSTNAME)

bootloader:
	@echo "Switching NixOS configuration..."
	sudo nixos-rebuild boot --install-bootloader --flake $(FLAKE)#$(HOSTNAME)

seed-iso:
	@echo "Generating Seed ISO..."
	export SSH_PRIVATE_HOST=$$(sops -d --extract '["ssh_private_seed"]' ./shared-secrets.yaml) && \
 	export SSH_PUBLIC_HOST=$$(sops -d --extract '["ssh_public_seed"]' ./shared-secrets.yaml) && \
	nix build --impure .#nixosConfigurations.seed.config.system.build.isoImage

burn-iso:
	@echo "Burning Seed ISO..."
	caligula burn result/iso/seed.iso -z none -s skip -f --root always

test-iso:
	@echo "Starting virtual machine"
	sudo virt-install \
	--name nixos-debug --os-variant nixos-unstable \
	--cdrom result/iso/seed.iso --boot cdrom \
	--memory 8192 --vcpus 12 --disk none \
	--graphics spice,listen=0.0.0.0 --video virtio --channel spicevmc,target_type=virtio,name=com.redhat.spice.0 \
	--noautoconsole --sound ich9 --network bridge=br0,model=virtio,mac=00:11:22:33:44:55 && \
	sudo -E virt-viewer --zoom=200 --wait nixos-debug && \
    sudo virsh destroy nixos-debug && \
	sudo virsh undefine nixos-debug

seed-debug:
	@echo "Generating Seed ISO..."
	export SSH_PRIVATE_HOST=$$(sops -d --extract '["ssh_private_seed"]' ./shared-secrets.yaml) && \
 	export SSH_PUBLIC_HOST=$$(sops -d --extract '["ssh_public_seed"]' ./shared-secrets.yaml) && \
	nix build --impure .#nixosConfigurations.seed.config.system.build.toplevel

deploy-sesame:
	@echo "Deploying Sesame configuration..."
    nix run github:numtide/nixos-anywhere -- --target-host nixos@sesame --flake .#sesame

help:
	@echo "Available targets:"
	@echo "  all     - Run both home and system targets (default)"
	@echo "  update  - Update flake inputs"
	@echo "  home    - Rebuild and switch home-manager configuration"
	@echo "  system  - Rebuild and switch NixOS configuration"
	@echo "  help    - Show this help message"
