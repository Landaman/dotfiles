{
  pkgs,
  config,
  lib,
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
    "com.apple.Home"
  ];

  # Globs that should never be shown, passed to FD and RG default arguments
  neverShowGlobs = [
    ".git/"
    ".DS_Store"
  ];
in
{
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
  };

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

    # The ** is necessary since otherwise this is ignored further down the tree
    # **/.husky/_/ this is currently BROKEN due to an issue in ripgrep itself (see https://github.com/BurntSushi/ripgrep/pull/2933 for updates)
    # Temporary fix for the above to exclude the .husky/_ dir. For some reason this has to be recursive
    **/_/ 

    !.env*
    !.vscode/
  '';

  home.file.".p10k.zsh".source = ./.p10k.zsh;

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

        alt-enter = ''''exec-and-forget osascript -e '
        if application "Ghostty" is running then
            tell application "System Events"
                tell application "Ghostty" to activate
                keystroke "n" using {command down}
            end tell
        else
            tell application "Ghostty" to activate
        end if
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
    initContent = lib.mkMerge [
      (lib.mkBefore ''
        if [[ -r "''${XDG_CACHE_HOME:-''$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-''$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '')
      (lib.mkBefore ''
        export FAST_WORK_DIR="$HOME/.zsh/plugins/zsh-fast-syntax-highlighting"
      '')
      ''
        ZSH_THEME_TERM_TITLE_IDLE="%~"

        export MANPAGER="sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman'"

        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      ''
    ];
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

          installPhase = oldAttrs.installPhase + ''
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
          nativeBuildInputs = oldAttrs.nativeBuildInputs or [ ] ++ [
            zsh
            gnused
          ];

          # This little bit of extra work automatically sets up catppuccin with FSH and
          # ensures the startup is zcompiled
          installPhase = oldAttrs.installPhase + ''
            env plugindir="$plugindir" zsh -c "$(cat << 'EOF'
              export FAST_WORK_DIR="$plugindir"
              source "$plugindir/fast-syntax-highlighting.plugin.zsh"
              fast-theme ${catppuccin-zsh-fsh}/themes/catppuccin-${config.catppuccin.flavor}
            EOF
            )"
            sed -zE -i 's|[[:blank:]]*if[[:blank:]]*\[\[ ! -w \$FAST_WORK_DIR \]\]; then\r?\n[[:blank:]]*FAST_WORK_DIR="\$\{XDG_CACHE_HOME:-\$HOME/\.cache\}/fsh"\r?\n[[:blank:]]*command mkdir -p "\$FAST_WORK_DIR"\r?\n[[:blank:]]*fi\r?\n?||g' $plugindir/fast-syntax-highlighting.plugin.zsh
          '';
          # Sed above is outside of heredoc so nix gets the right sed (gnused). Also, use that grossness so that FSH is okay with an immutable $FAST_WORK_DIR
        });
        path = "zsh/site-functions";
        file = "fast-syntax-highlighting.plugin.zsh";
      })
      (packageWithZCompile {
        package = zsh-autosuggestions;
        path = "zsh-autosuggestions";
        file = "zsh-autosuggestions.zsh";
      })
      # No ZCompile bc this has nothing to source - it only adds completions to fpath
      {
        name = zsh-completions.pname;
        src = "${zsh-completions}/share/zsh/site-functions";
      }
    ];
  };

  programs.ghostty.enable = true;

  programs.zoxide.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraPackages = with pkgs; [
      tree-sitter
    ];
  };

  programs.fzf = rec {
    enable = true;
    defaultCommand = ''
      fd --type f --follow --strip-cwd-prefix --color=never --hidden ${
        lib.concatMapStringsSep " " (globPattern: "--exclude=${globPattern}") neverShowGlobs
      }
    '';
    fileWidgetCommand = "${defaultCommand}";
    changeDirWidgetCommand = ''
      fd --type d --follow --color=never --hidden ${
        lib.concatMapStringsSep " " (globPattern: "--exclude=${globPattern}") neverShowGlobs
      }
    '';
    defaultOptions = [
      "--tmux"
      "--multi"
    ];
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
    delta = {
      enable = true;
      options = {
        navigate = true;
      };
    };
    extraConfig = {
      init.defaultBranch = "main";
      merge.tool = "nvimdiff";
      merge.conflictstyle = "zdiff3";

    };
  };

  # Packages available to only this user
  home.packages = with pkgs; [
    awscli2
    terraform
    aerospace
    bruno
    wireshark
    bitwarden-cli
    nixd
    nixfmt-rfc-style
    sqlite
    raycast
    cyberduck
    nosql-workbench
    utm
    spotify
    discord
    vscode
    zoxide-fzf-tmux-session
    fastmod
  ];
}
