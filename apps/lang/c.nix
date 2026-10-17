{
  config,
  lib,
  pkgs,
  ...
}:
let
  username = config.user.username;
in
{
  home-manager.users.${username} = {
    programs.neovim = {
      extraPackages = with pkgs; [
        clang-tools
      ];

      lzePlugins = {
        nvim-treesitter.options = [
          {
            ensure_installed = [
              "c"
            ];
          }
        ];

        nvim-lspconfig.options = [
          {
            config.clangd = { };
          }
        ];
      };
    };

    programs.vscode.profiles.default =
      lib.mkIf config.home-manager.users.${username}.programs.vscode.enable
        {
          extensions = [
            pkgs.vscode-extensions.ms-vscode.cpptools-extension-pack
            pkgs.vscode-extensions.ms-vscode.cpptools
            (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
              mktplcRef = {
                publisher = "ms-vscode";
                name = "cpptools-themes";
                version = "2.0.0";
                hash = "sha256-YWA5UsA+cgvI66uB9d9smwghmsqf3vZPFNpSCK+DJxc=";
              };
            })
            pkgs.vscode-extensions.ms-vscode.cmake-tools
            (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
              mktplcRef = {
                publisher = "cschlosser";
                name = "doxdocgen";
                version = "1.4.0";
                hash = "sha256-InEfF1X7AgtsV47h8WWq5DZh6k/wxYhl2r/pLZz9JbU=";
              };
            })
            (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
              mktplcRef = {
                publisher = "ms-vscode";
                name = "cpp-devtools";
                version = "0.5.13";
                hash = "sha256-g8ZXdEgKB6okJEVXvFQMGz5oDMsOh5mWzl50B/etVjw=";
              };
            })
          ];
        };
  };
}
