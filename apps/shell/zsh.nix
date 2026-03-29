{
  pkgs,
  config,
  lib,
  ...
}:
let
  zshUtils = (
    import ../../lib/zsh-utils.nix {
      inherit pkgs;
    }
  );
  packageWithZCompile = zshUtils.packageWithZCompile;

  ohMyZshCloneOnly = pkgs.oh-my-zsh.overrideAttrs (oldAttrs: {
    installPhase = ''
      outdir=$out/share/oh-my-zsh

      mkdir -p $outdir
      cp -r * $outdir
    '';
  });
in
{
  options.zsh = {
    fast-theme = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "The theme to use for zsh-fast-syntax-highlighting.";
    };
  };

  config.home-manager.users.${config.user.username} = {
    home.file.".p10k.zsh".source = ./.p10k.zsh;

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
                ${if config.zsh.fast-theme != null then "fast-theme ${config.zsh.fast-theme}" else ""}
              EOF
              )"
              sed -zE -i 's|[[:blank:]]*if[[:blank:]]*\[\[ ! -w \$FAST_WORK_DIR \]\]; then\r?\n[[:blank:]]*FAST_WORK_DIR="\$\{XDG_CACHE_HOME:-\$HOME/\.cache\}/fsh"\r?\n[[:blank:]]*command mkdir -p "\$FAST_WORK_DIR"\r?\n[[:blank:]]*fi\r?\n?||g' $plugindir/fast-syntax-highlighting.plugin.zsh
            '';
            # Sed above is outside of heredoc so nix gets the right sed (gnused). Also, use that grossness so that FSH is okay with an immutable $FAST_WORK_DIR
          });
          path = "zsh/plugins/fast-syntax-highlighting";
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
  };
}
