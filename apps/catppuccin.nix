{
  config,
  lib,
  ...
}:
{
  home-manager.users.${config.user.username} = {
    catppuccin = {
      flavor = "mocha";
      ghostty.enable = true;
      bat.enable = true;
      delta.enable = true;
      tmux = {
        enable = true;
        extraConfig = "set -g @catppuccin_window_status_style \"none\"";
      };
      fzf.enable = true;
      lazygit.enable = true;
    };

    programs.fzf = {
      # TODO: If catppuccin/nix ever gets fixed, migrate to completely that instead of this nonsense
      colors = {
        hl = lib.mkForce "#f38ba8";
        header = lib.mkForce "#f38ba8";
        pointer = lib.mkForce "#f5e0dc";
        marker = lib.mkForce "#b4befe";
        "hl+" = lib.mkForce "#f38ba8";
        selected-bg = lib.mkForce "#45475a";
        border = lib.mkForce "#313244";
        label = lib.mkForce "#CDD6F4";
      };
    };
  };
}
