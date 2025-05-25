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

  floatingApps = [
    "com.apple.MobileSMS"
    "com.hnc.Discord"
    "com.facebook.archon"
    "com.apple.mail"
    "com.apple.Music"
    "com.apple.iBooksX"
    "com.apple.podcasts"
    "com.bitwarden.desktop"
    "com.apple.iCal"
    "net.whatsapp.WhatsApp"
    "com.apple.weather"
    "com.spotify.client"
    "com.flightyapp.flighty"
  ];

  # Globs that should never be shown, passed to FD and RG default arguments
  neverShowGlobs = [
    ".git/"
    ".DS_Store"
  ];
in
{
  # Tell Home Manager who it is managing in this config
  home.username = "ianwright";
  home.homeDirectory = "/Users/ianwright";

  # Used for backwards compatibility, please read the changelog before changing.
  home.stateVersion = "24.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # This file will be respected by fd and ripgrep whenever you're in a subdirectory of home (most things)
  # AND it overrides .gitignore, even with ! patterns (careful with subdirectories - if they are not traversed, you can't unignore files in them!)
  home.file.".ignore".text = ''
    metals.sbt
    node_modules/
    .venv/
    __pycache__/
    .metals/
    .bloop/
    .ammonite/
    .turbo/
    .yarn/
    .firebase/
    .next/
    .svelte-kit/
    .husky/_

    !.env*
    !.vscode/
    !.vscode/**/*
  '';

  home.file.".p10k.zsh".source = ./.p10k.zsh;

  # Link themes for catpuccin fsh
  home.file."${config.xdg.configHome}/fsh".source = "${catppuccinFsh}/themes";

  home.file.".aerospace.toml".text = ''
    start-at-login = true

    accordion-padding = 30

    on-focused-monitor-changed = ['move-mouse monitor-lazy-center']

    ${builtins.concatStringsSep "\n" (
      builtins.map (appId: ''
        [[on-window-detected]]
         if.app-id="${appId}"
         run= [
           "layout floating",
         ] 
      '') floatingApps
    )}

    [mode.main.binding]
        alt-slash = 'layout tiles horizontal vertical'
        alt-comma = 'layout accordion horizontal vertical'

        alt-enter = ''''exec-and-forget sh -c '
          CURRENT_WORKSPACE=$(aerospace list-workspaces --focused)

          osascript -e "
            if application \"Ghostty\" is running then
              tell application \"System Events\"
                tell application \"Ghostty\" to activate
                keystroke \"n\" using {command down}
              end tell
            else
              tell application \"Ghostty\" to activate
            end if
          "

          aerospace move-node-to-workspace $CURRENT_WORKSPACE
          aerospace summon-workspace $CURRENT_WORKSPACE
        '
        ''''

        alt-shift-enter = ''''exec-and-forget osascript -e '
        if application "Safari" is running then
            tell application "Safari" to make new document
        else
            tell application "Safari" to activate
        end if
        '
        ''''

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
        alt-0 = 'balance-sizes'

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

        alt-p = 'workspace prev --wrap-around'
        alt-n = 'workspace next --wrap-around'

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
        fd --type f --follow --color=never --hidden "$1"
      }

      _fzf_compgen_dir() {
        fd --type d --follow --color=never --hidden "$1";
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
      fd --type f --follow --strip-cwd-prefix --color=never --hidden
    '';
    fileWidgetCommand = "${defaultCommand}";
    changeDirWidgetCommand = ''
      fd --type d --follow --color=never --hidden
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
      theme = "Catppuccin Mocha";
    };
    themes = {
      "Catppuccin Mocha" = {
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

  programs.fd = {
    enable = true;
    # This effectively always hides .git and DS_Store via a shell alias. Using \fd should prevent that, if desired
    extraOptions = builtins.map (globPattern: "--exclude=${globPattern}") neverShowGlobs;
  };

  programs.ripgrep = {
    enable = true;
    # This effectively always hides .git and DS_Store via the ripgrep config sytnax
    arguments = builtins.map (globPattern: "--glob=!${globPattern}") neverShowGlobs;
  };

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
    includes = [
      {
        path = "${
          pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "delta";
            rev = "e9e21cffd98787f1b59e6f6e42db599f9b8ab399";
            hash = "sha256-04po0A7bVMsmYdJcKL6oL39RlMLij1lRKvWl5AUXJ7Q=";
          }
        }/catppuccin.gitconfig";
      }
    ];
    extraConfig = {
      init.defaultBranch = "main";
      merge.tool = "nvimdiff";
      diff.tool = "nvimdiff";
      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
      delta.navigate = true;
      delta.features = "catppuccin-mocha";
      merge.conflictstyle = "zdiff3";

    };
  };

  # Packages available to only this user
  home.packages = with pkgs; [
    aerospace
    wireshark
    bitwarden-cli
    nixd
    delta
    nixfmt-rfc-style
    sqlite
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
