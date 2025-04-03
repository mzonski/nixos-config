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

init-iso:
	@echo "Generating Init ISO..."
	nix build .#nixosConfigurations.init.config.system.build.isoImage

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
