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
    programs.neovim.mason.packages = [ "gopls" ];
    home.packages = with pkgs; [
      go
      gopls
      gotools
    ];

    programs.neovim = {
      lzePlugins = {
        nvim-treesitter.options = [
          {
            ensure_installed = [
              "go"
              "gomod"
              "gosum"
              "gowork"
            ];
          }
        ];

        nvim-lspconfig.options = [
          {
            config.gopls = { };
          }
        ];

        conform-nvim.options = [
          {
            formatters_by_ft.go = [ "gofmt" ];
          }
        ];
      };
    };

    programs.vscode.profiles.default =
      lib.mkIf config.home-manager.users.${username}.programs.vscode.enable
        {
          extensions = [ pkgs.vscode-extensions.golang.go ];
        };
  };
}
