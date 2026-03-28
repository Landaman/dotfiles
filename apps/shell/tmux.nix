{
  config,
  pkgs,
  ...
}:
let
  username = config.user.username;
in
{
  home-manager.users.${username} = {
    programs.tmux = {
      enable = true;
      terminal = "tmux-256color";
      shortcut = "a";
      mouse = true;
      focusEvents = true;
      baseIndex = 1;
      aggressiveResize = true;
      historyLimit = 5000;
      escapeTime = 5;
      extraConfig = ''
        set -g status-interval 5
        set -g renumber-windows on
        set -g set-titles on
        set -g set-titles-string "tmux #S"

        set -g status-keys emacs
        set-window-option -g mode-keys vi

        bind C-p previous-window
        bind C-n next-window
        bind a last-window

        bind Z run-shell tmux-session

        set -g status-left-length 100
      '';
      plugins = with pkgs.tmuxPlugins; [
        {
          plugin = pain-control;
        }
        {
          plugin = fingers;
          extraConfig = ''
            set -g @fingers-backdrop-style "dim"
          '';
        }
        {
          plugin = open;
        }
      ];
    };

    programs.fzf = {
      enable = true;
      defaultOptions = [ "--tmux" ];
      tmux = {
        enableShellIntegration = true;
        shellIntegrationOptions = [ "-p" ];
      };
    };
  };
}
