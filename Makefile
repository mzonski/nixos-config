FLAKE    := .
USERNAME := $(shell whoami)
HOSTNAME := $(shell hostname)

SEED_SSH_ENV = \
	export SSH_PRIVATE_HOST=$$(sops -d --extract '["ssh_private_$(1)"]' ./shared-secrets.yaml) && \
	export SSH_PUBLIC_HOST=$$(sops -d --extract '["ssh_public_$(1)"]' ./shared-secrets.yaml)

.DEFAULT_GOAL := help

.PHONY: help all update clean \
	home switch switch-revert sysboot bootloader \
	build kernel \
	seed-iso build-seed burn-seed test-seed \
	edit-secrets

help: ## Show this help message
	@awk 'BEGIN {FS = ":.*## "} /^[a-zA-Z0-9%_-]+:.*## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

##@ Maintenance

update: ## Update flake inputs
	@echo "Updating flake inputs..."
	nix flake update

clean: ## Remove old generations and collect garbage
	@echo "Cleaning old generations..."
	sudo ./utils/clear-nix-profiles.sh remove
	nix-collect-garbage --delete-old
	nix-store --gc --print-roots | egrep -v "^(/nix/var|/run/\w+-system|\{memory|/proc)"

##@ Local machine

home: ## Build and switch home-manager configuration
	@echo "Switching home-manager configuration..."
	home-manager build --flake $(FLAKE)#$(USERNAME)@$(HOSTNAME)
	home-manager switch --flake $(FLAKE)#$(USERNAME)@$(HOSTNAME)

switch: ## Switch NixOS configuration
	@echo "Switching NixOS configuration..."
	nixos-rebuild switch --sudo --flake $(FLAKE)#$(HOSTNAME)
	sync

switch-revert: ## Rollback to the previous NixOS configuration
	@echo "Switching to previous NixOS configuration..."
	nixos-rebuild switch --sudo --flake $(FLAKE)#$(HOSTNAME) --rollback

sysboot: ## Build NixOS configuration for next boot
	@echo "Building new boot NixOS configuration..."
	nixos-rebuild boot --sudo --flake $(FLAKE)#$(HOSTNAME)

bootloader: ## Build NixOS configuration for next boot and reinstall bootloader
	@echo "Installing bootloader and building new boot NixOS configuration..."
	nixos-rebuild boot --install-bootloader --sudo --flake $(FLAKE)#$(HOSTNAME)

##@ Builds

build: build-$(HOSTNAME) ## Build the system of this host

build-%: ## Build the system of host %
	@echo "Building system for $*..."
	systemd-inhibit nix build .#nixosConfigurations.$*.config.system.build.toplevel

kernel: kernel-$(HOSTNAME) ## Build the kernel of this host

kernel-%: ## Build the kernel of host %
	@echo "Building kernel for $*..."
	time systemd-inhibit nix build .#nixosConfigurations.$*.config.boot.kernelPackages.kernel

##@ Remote machines

sysboot-%: ## Build NixOS configuration for next boot on host %
	@echo "Building new boot NixOS configuration for remote machine..."
	nixos-rebuild boot \
		--flake ".#$*" \
		--target-host "$(USERNAME)@$*" \
		--build-host localhost \
		--sudo

bootloader-%: ## Reinstall bootloader on host %
	@echo "Updating bootloader on remote machine..."
	nixos-rebuild boot --install-bootloader \
		--flake ".#$*" \
		--target-host "$(USERNAME)@$*" \
		--build-host localhost \
		--sudo

deploy-%: ## Deploy new configuration to host %
	@echo "Deploying new configuration..."
	./utils/deploy-host.sh $* $(USERNAME)

update-%: ## Update host %
	@echo "Updating remote machine..."
	./utils/update-host.sh $* $(USERNAME)

reboot-%: ## Reboot host %
	@echo "Rebooting remote machine..."
	ssh $(USERNAME)@$* "sudo reboot"

##@ ISO images

seed-iso: ## Generate the Seed ISO
	@echo "Generating Seed ISO..."
	$(call SEED_SSH_ENV,seed) && \
	nix build --impure .#nixosConfigurations.seed.config.system.build.isoImage

build-seed: ## Build the Seed toplevel
	@echo "Generating Seed ISO..."
	$(call SEED_SSH_ENV,seed) && \
	nix build --impure .#nixosConfigurations.seed.config.system.build.toplevel

burn-seed: ## Burn the Seed ISO to a USB drive
	@echo "Burning Seed ISO..."
	$(eval OUTPUT_DEVICE := $(shell udevadm info --name=/dev/sda | grep -q "ID_VENDOR=SanDisk" && udevadm info --name=/dev/sda | grep -q "ID_MODEL=Ultra" && echo "/dev/sda" || echo ""))
	caligula burn result/iso/seed.iso -z none -s skip -f --root always $(if $(OUTPUT_DEVICE),-o $(OUTPUT_DEVICE))

test-seed: ## Boot the Seed ISO in a virtual machine
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

graft-iso-%: ## Generate the Graft ISO of host %
	@echo "Generating Graft ISO for $*..."
	$(call SEED_SSH_ENV,$*) && \
	nix build --impure .#nixosConfigurations.graft-$*.config.system.build.isoImage

##@ Secrets

edit-secrets: ## Edit shared secrets
	export SOPS_AGE_KEY=$(sudo ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key) && \
	sops shared-secrets.yaml
	sops updatekeys shared-secrets.yaml

edit-secrets-%: ## Edit secrets of host %
	sops hosts/$*/secrets.yaml
	sops updatekeys hosts/$*/secrets.yaml

rotate-secrets-%: ## Re-encrypt secrets of host %
	sops -d hosts/$*/secrets.yaml > hosts/$*/secrets.decrypted.yaml
	rm hosts/$*/secrets.yaml
	mv hosts/$*/secrets.decrypted.yaml hosts/$*/secrets.yaml
	sops -e hosts/$*/secrets.yaml > hosts/$*/secrets.encrypted.yaml
	rm hosts/$*/secrets.yaml
	mv hosts/$*/secrets.encrypted.yaml hosts/$*/secrets.yaml
