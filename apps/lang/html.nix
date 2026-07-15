{
  config,
  pkgs,
  ...
}:
let
  username = config.user.username;
in
{
  home-manager.users.${username}.programs.neovim = {
    extraPackages = with pkgs; [
      prettierd
      vscode-langservers-extracted
    ];

    lzePlugins = {
      nvim-treesitter.options = [
        {
          ensure_installed = [
            "html"
          ];
        }
      ];

      nvim-lspconfig.options = [
        {
          config.html = { };
        }
      ];

      conform-nvim.options = [
        {
          formatters_by_ft.html = [ "web" ];
        }
      ];
    };
  };
}
