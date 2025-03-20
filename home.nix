{
  pkgs,
  config,
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

  catppuccinFsh = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "zsh-fsh";
    rev = "a9bdf479f8982c4b83b5c5005c8231c6b3352e2a";
    hash = "sha256-WeqvsKXTO3Iham+2dI1QsNZWA8Yv9BHn1BgdlvR8zaw=";
  };
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

  # Link themes for catpuccin fsh
  home.file."${config.xdg.configHome}/fsh".source = "${catppuccinFsh}/themes";

  home.file.".aerospace.toml".text = ''
    start-at-login = true

    accordion-padding = 30

    on-focused-monitor-changed = ['move-mouse monitor-lazy-center']

    [mode.main.binding]
        alt-slash = 'layout tiles horizontal vertical'
        alt-comma = 'layout accordion horizontal vertical'

        alt-h = 'focus left'
        alt-j = 'focus down'
        alt-k = 'focus up'
        alt-l = 'focus right'

        alt-shift-h = 'move left'
        alt-shift-j = 'move down'
        alt-shift-k = 'move up'
        alt-shift-l = 'move right'

        alt-minus = 'resize smart -50'
        alt-equal = 'resize smart +50'

        alt-1 = 'workspace 1'
        alt-2 = 'workspace 2'
        alt-3 = 'workspace 3'
        alt-4 = 'workspace 4'
        alt-5 = 'workspace 5'
        alt-6 = 'workspace 6'
        alt-7 = 'workspace 7'
        alt-8 = 'workspace 8'
        alt-9 = 'workspace 9'

        alt-shift-1 = 'move-node-to-workspace 1'
        alt-shift-2 = 'move-node-to-workspace 2'
        alt-shift-3 = 'move-node-to-workspace 3'
        alt-shift-4 = 'move-node-to-workspace 4'
        alt-shift-5 = 'move-node-to-workspace 5'
        alt-shift-6 = 'move-node-to-workspace 6'
        alt-shift-7 = 'move-node-to-workspace 7'
        alt-shift-8 = 'move-node-to-workspace 8'
        alt-shift-9 = 'move-node-to-workspace 9'

        alt-tab = 'workspace-back-and-forth'

        alt-shift-tab = 'move-workspace-to-monitor --wrap-around next'

        alt-shift-semicolon = 'mode service'

    [mode.service.binding]
        esc = ['reload-config', 'mode main']
        r = ['flatten-workspace-tree', 'mode main']
        f = ['layout floating tiling', 'mode main']
        backspace = ['close-all-windows-but-current', 'mode main']

        alt-shift-h = ['join-with left', 'mode main']
        alt-shift-j = ['join-with down', 'mode main']
        alt-shift-k = ['join-with up', 'mode main']
        alt-shift-l = ['join-with right', 'mode main']
  '';

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

      export MANPAGER="sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman'"

      _fzf_compgen_path() {
        fdi --type f --follow --color=never --hidden "$1"
      }

      _fzf_compgen_dir() {
        fdi --type d --follow --color=never --hidden "$1";
      }

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
        package = zsh-fast-syntax-highlighting.overrideAttrs (oldAttrs: {
          nativeBuildInputs = oldAttrs.nativeBuildInputs or [ ] ++ [ zsh ];

          # This little bit of extra work automatically sets up catppuccin with FSH
          installPhase =
            oldAttrs.installPhase
            + ''
              env plugindir="$plugindir" zsh -c '
                export FAST_WORK_DIR="$plugindir"
                source "$plugindir/fast-syntax-highlighting.plugin.zsh"
                fast-theme ${catppuccinFsh}/themes/catppuccin-mocha
              '
            '';
        });
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

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.fzf = rec {
    enable = true;
    defaultCommand = ''
      fdi --type f --follow --strip-cwd-prefix --color=never --hidden
    '';
    fileWidgetCommand = "${defaultCommand}";
    changeDirWidgetCommand = ''
      fdi --type d --follow --color=never --hidden
    '';
    defaultOptions = [
      "--tmux"
      "--multi"
    ];
    colors = {
      spinner = "#f5e0dc";
      bg = "#1e1e2e";
      "bg+" = "#313244";
      hl = "#f38ba8";
      fg = "#cdd6f4";
      header = "#f38ba8";
      info = "#cba6f7";
      pointer = "#f5e0dc";
      marker = "#b4befe";
      prompt = "#cba6f7";
      "hl+" = "#f38ba8";
      selected-bg = "#45475a";
    };
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
    '';
    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_window_status_style "none"
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

  programs.bat = {
    enable = true;
    config = {
      theme = "catppuccin";
    };
    themes = {
      catppuccin = {
        src = "${
          pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "bat";
            rev = "699f60fc8ec434574ca7451b444b880430319941";
            sha256 = "sha256-6fWoCH90IGumAMc4buLRWL0N61op+AuMNN9CAR9/OdI=";
          }
        }/themes";
        file = "Catppuccin Mocha.tmTheme";
      };
    };
    extraPackages = with pkgs.bat-extras; [
      batdiff
      batman
      batgrep
    ];
  };

  programs.fd.enable = true;

  programs.google-chrome = {
    enable = true;
  };
  home.file."Library/Application Support/Google/Chrome/External Extensions/blipmdconlkpinefehnmjammfjpmpbjk.json".text =
    ''
      {
        "external_update_url": "https://clients2.google.com/service/update2/crx"
      }
    '';

  programs.git = {
    enable = true;
    userName = "Ian Wright";
    userEmail = "49083526+Landaman@users.noreply.github.com";
    extraConfig = {
      merge.tool = "nvimdiff";
      diff.tool = "nvimdiff";
    };
  };

  # Packages available to only this user
  home.packages = with pkgs; [
    aerospace
    wireshark
    bitwarden-cli
    nixd
    nixfmt-rfc-style
    sqlite
    ripgrep # NeoVim dependency
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
    find-directory-ignore
    ripgrep-ignore
  ];
}
