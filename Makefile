################################################
# Supported commands:
# home-manager build --flake .#zonni@corn
# home-manager switch --flake .#zonni@corn
# 
# sudo nixos-rebuild switch --flake .#corn
# nix flake update
################################################

FLAKE := .
USERNAME := zonni
HOSTNAME := corn

.PHONY: all home system update

all: home system

update:
	@echo "Updating flake inputs..."
	nix flake update

clean:
	@echo "Cleaning old generations..."
	nix-collect-garbage --delete-old

home:
	@echo "Switching home-manager configuration..."
	home-manager build --flake $(FLAKE)#$(USERNAME)@$(HOSTNAME)
	home-manager switch --flake $(FLAKE)#$(USERNAME)@$(HOSTNAME)

zhomes:
	@echo "Switching cracked home-manager configuration..."
	home-manager build --flake .#zonni@corn --extra-experimental-features nix-command --extra-experimental-features flakes
	home-manager switch --flake .#zonni@corn --extra-experimental-features nix-command --extra-experimental-features flakes

system:
	@echo "Switching NixOS configuration..."
	sudo nixos-rebuild switch --flake $(FLAKE)#$(HOSTNAME)

help:
	@echo "Available targets:"
	@echo "  all     - Run both home and system targets (default)"
	@echo "  update  - Update flake inputs"
	@echo "  home    - Rebuild and switch home-manager configuration"
	@echo "  system  - Rebuild and switch NixOS configuration"
	@echo "  help    - Show this help message"
