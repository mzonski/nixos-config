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

system-revert:
	@echo "Switching to previous NixOS configuration..."
	sudo nixos-rebuild switch --flake $(FLAKE)#$(HOSTNAME) --rollback

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
	$(eval OUTPUT_DEVICE := $(shell udevadm info --name=/dev/sda | grep -q "ID_VENDOR=SanDisk" && udevadm info --name=/dev/sda | grep -q "ID_MODEL=Ultra" && echo "/dev/sda" || echo ""))
	caligula burn result/iso/seed.iso -z none -s skip -f --root always $(if $(OUTPUT_DEVICE),-o $(OUTPUT_DEVICE))

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


edit-secrets:
	export SOPS_AGE_KEY=$(sudo ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key) && \
	sops shared-secrets.yaml
	sops updatekeys shared-secrets.yaml

edit-secrets-%:
	sops hosts/$*/secrets.yaml
	sops updatekeys hosts/$*/secrets.yaml

rotate-secrets-%:
	sops -d hosts/$*/secrets.yaml > hosts/$*/secrets.decrypted.yaml
	rm hosts/$*/secrets.yaml
	mv hosts/$*/secrets.decrypted.yaml hosts/$*/secrets.yaml
	sops -e hosts/$*/secrets.yaml > hosts/$*/secrets.encrypted.yaml
	rm hosts/$*/secrets.yaml
	mv hosts/$*/secrets.encrypted.yaml hosts/$*/secrets.yaml

deploy-%:
	@echo "Deploying new configuration..."
	./utils/deploy-host.sh $* $(USERNAME)

update-%:
	@echo "Updating remote machine..."
	./utils/update-host.sh $* $(USERNAME)

reboot-%:
	@echo "Rebooting remote machine..."
	ssh $(USERNAME)@$* "sudo reboot"

help:
	@echo "Available targets:"
	@echo "  all     - Run both home and system targets (default)"
	@echo "  update  - Update flake inputs"
	@echo "  home    - Rebuild and switch home-manager configuration"
	@echo "  system  - Rebuild and switch NixOS configuration"
	@echo "  help    - Show this help message"
