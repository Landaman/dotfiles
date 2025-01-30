{
  pkgs,
  ...
}:
let
  zshUtils = (
    import ./zsh-utils.nix {
      inherit pkgs;
    }
  );
  packageWithZCompile = zshUtils.packageWithZCompile;
  packageWithZCompileAll = zshUtils.packageWithZCompileAll;

  ohMyZshCloneOnly = pkgs.oh-my-zsh.overrideAttrs (oldAttrs: {
    installPhase = ''
      outdir=$out/share/oh-my-zsh

      mkdir -p $outdir
      cp -r * $outdir
    '';
  });

in
{
  # Tell Home Manager who it is managing in this config
  home.username = "ianwright";
  home.homeDirectory = "/Users/ianwright";

  # Used for backwards compatibility, please read the changelog before changing.
  home.stateVersion = "24.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.file.".p10k.zsh".source = ./.p10k.zsh;

  # ZSH config
  programs.zsh = {
    enable = true;
    initExtraFirst = ''
      if [[ -r "''${XDG_CACHE_HOME:-''$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-''$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi
    '';
    initExtra = ''
      ZSH_THEME_TERM_TITLE_IDLE="%~"

      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
    '';
    plugins = with pkgs; [
      (packageWithZCompile rec {
        name = "omz-lib";
        package = ohMyZshCloneOnly.overrideAttrs (oldAttrs: rec {
          libFiles = [
            "functions.zsh"
            "theme-and-appearance.zsh"
            "termsupport.zsh"
            "completion.zsh"
            "misc.zsh"
            "key-bindings.zsh"
          ];

          installPhase =
            oldAttrs.installPhase
            + ''
              echo "${
                pkgs.lib.concatStrings (
                  map (file: ''
                    source "${file}"
                  '') libFiles
                )
              }" >> $out/share/${path}/${file}
            '';
        });
        file = "omz.zsh";
        path = "oh-my-zsh/lib";
      })
      (packageWithZCompile {
        name = "colored-man-pages";
        package = ohMyZshCloneOnly;
        path = "oh-my-zsh/plugins/colored-man-pages";
        file = "colored-man-pages.plugin.zsh";
      })
      (packageWithZCompile {
        package = zsh-fast-syntax-highlighting;
        path = "zsh/site-functions";
        file = "fast-syntax-highlighting.plugin.zsh";
      })
      (packageWithZCompile {
        package = zsh-autosuggestions;
        path = "zsh-autosuggestions";
        file = "zsh-autosuggestions.zsh";
      })
      {
        name = zsh-completions.pname;
        src = "${zsh-completions}/share/zsh/site-functions";
      }
      {
        name = awscli2.pname;
        file = "bin/aws_zsh_completer.sh";
        src = "${awscli2}";
      }
    ];
  };

  programs.ghostty = {
    enable = true;
    settings = {
      theme = "catppuccin-mocha";
      quit-after-last-window-closed = true;
    };
  };
  programs.zoxide.enable = true;
  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;
  programs.fzf = {
    enable = true;
    defaultOptions = [ "--tmux" ];
    tmux = {
      enableShellIntegration = true;
      shellIntegrationOptions = [ "-p" ]; # Render as a Tmux popup with shell integration
    };
  };
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
      bind Z run-shell tmux-session

      set -g status-left-length 100
      set -g status-left "#{E:@catppuccin_status_session}"

      set -g status-right-length 100
      set -g status-right "#{E:@catppuccin_status_user}"
      set -ag status-right "#{E:@catppuccin_status_directory}"
    '';
    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor 'mocha'
          set -gq @catppuccin_window_text " #W"
          set -gq @catppuccin_window_current_text " #W"
          set -gq @catppuccin_status_left_separator "█"
          set -gq @catppuccin_status_middle_separator ""
          set -gq @catppuccin_status_right_separator "█"
        '';
      }
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

  # Packages available to only this user
  home.packages = with pkgs; [
    wireshark
    bitwarden-cli
    nixd
    nixfmt-rfc-style
    sqlite
    ripgrep # NeoVim dependency
    fd # NeoVim dependency
    tree-sitter # NeoVim dependency
    raycast
    cyberduck
    nosql-workbench
    postman
    utm
    spotify
    discord
    vscode
    zoxide-fzf-tmux-session
  ];
}
