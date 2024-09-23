# Makefile for NixOS and Home Manager

# Variables
FLAKE := .
USERNAME := zonni
HOSTNAME := pc-linux

# Phony targets
.PHONY: all home system update

# Default target
all: home system

# Update flake inputs
update:
	@echo "Updating flake inputs..."
	nix flake update

# Switch home-manager configuration
home:
	@echo "Switching home-manager configuration..."
	home-manager build --flake $(FLAKE)#$(USERNAME)@$(HOSTNAME)
	home-manager switch --flake $(FLAKE)#$(USERNAME)@$(HOSTNAME)

# Rebuild and switch NixOS configuration
system:
	@echo "Switching NixOS configuration..."
	sudo nixos-rebuild switch --flake $(FLAKE)#$(HOSTNAME)

# Help target
help:
	@echo "Available targets:"
	@echo "  all     - Run both home and system targets (default)"
	@echo "  update  - Update flake inputs"
	@echo "  home    - Rebuild and switch home-manager configuration"
	@echo "  system  - Rebuild and switch NixOS configuration"
	@echo "  help    - Show this help message"
