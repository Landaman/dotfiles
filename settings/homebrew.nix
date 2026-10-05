{ lib, ... }:
{
  # Setup homebrew and install necessary dependencies
  homebrew.enable = true;
  # Uninstall all Casks/Brews not specified here on activation
  homebrew.onActivation.cleanup = lib.mkDefault "zap"; # Zap removes associated files for casks (just in brew directory, not ~/.config etc.)
}
