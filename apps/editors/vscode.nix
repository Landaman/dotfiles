{
  config,
  lib,
  pkgs,
  ...
}:
let
  username = config.user.username;
  neovim = config.home-manager.users.${username}.programs.neovim;

  # We only care about directories here (we'll tell the watcher not to include them)
  # so filter globs to that
  excludedDirectories =
    map
      (
        glob:
        if lib.hasPrefix "**/" glob then lib.removeSuffix "/" glob else "**/${lib.removeSuffix "/" glob}"
      )
      (
        builtins.filter (glob: lib.hasSuffix "/" glob && !lib.hasPrefix "!" glob) config.files.ignoreGlobs
      );
in
{
  home-manager.users.${username}.programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;

    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;

      extensions =
        with pkgs.vscode-extensions;
        [
          editorconfig.editorconfig

          ms-vscode-remote.remote-containers
          ms-vscode-remote.remote-ssh
          ms-vscode-remote.remote-ssh-edit
          ms-vscode.remote-explorer

          vscode-icons-team.vscode-icons
          (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
            mktplcRef = {
              publisher = "fabiospampinato";
              name = "vscode-diff";
              version = "2.1.2";
              hash = "sha256-gpWvu1eZ+N2jNh2Pu0jilOWxL0XJ4vKW3Fvq+M/WHsU=";
            };
          })
          (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
            mktplcRef = {
              publisher = "Syler";
              name = "ignore";
              version = "0.0.7";
              hash = "sha256-ekt74buCPD6aR7togBRkcOgWU8RH2oSRgm8vTmCgmGY=";
            };
          })
        ]
        ++ lib.optional neovim.enable pkgs.vscode-extensions.asvetliakov.vscode-neovim;

      userSettings = {
        "files.enableTrash" = false;
        "files.watcherExclude" = lib.genAttrs (map (dir: "${dir}/**") excludedDirectories) (_: true);

        "editor.minimap.enabled" = false;
        "editor.formatOnSave" = true;
        "explorer.decorations.badges" = false;
        "editor.inlayHints.enabled" = "off";

        # Use the .ignore file in the home directory we use for everything else
        "search.useIgnoreFiles" = true;
        "search.useParentIgnoreFiles" = true;

        "workbench.iconTheme" = "vscode-icons";
      }
      // lib.optionalAttrs neovim.enable {
        "extensions.experimental.affinity"."asvetliakov.vscode-neovim" = 1;
        "vscode-neovim.neovimExecutablePaths.darwin" = "${neovim.finalPackage}/bin/nvim";
      };
    };
  };
}
