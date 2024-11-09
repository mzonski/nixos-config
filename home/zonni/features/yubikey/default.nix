{ pkgs, ... }:
{
  home.packages = (
    with pkgs;
    [
      yubikey-manager # Main CLI tool for YubiKey management (ykman)
      yubico-piv-tool # Specific tool for PIV operations
      opensc # Smart card utilities and libraries
      pcsctools # PC/SC tools for smart card operations

      # Certificate management tools
      openssl # For certificate operations

      # Optional but useful tools
      ccid # Smart card driver
      paperkey # Backup tool for keys
      kleopatra # Certificate manager and GUI for OpenPGP and CMS cryptography
    ]
  );
}
