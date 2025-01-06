{
  pkgs,
  ...
}:
{
  # Tell Home Manager who it is managing in this config
  home.username = "ianwright";
  home.homeDirectory = "/Users/ianwright";

  # Used for backwards compatibility, please read the changelog before changing.
  home.stateVersion = "24.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Packages available to only this user
  home.packages = [
    pkgs.bitwarden-cli
    pkgs.nixd
    pkgs.nixfmt-rfc-style
    pkgs.neovim
    pkgs.sqlite
    pkgs.neovim
    pkgs.ripgrep # NeoVim dependency
    pkgs.fd # NeoVim dependency
    pkgs.tree-sitter # NeoVim dependenvy
    pkgs.wezterm
  ];
}
