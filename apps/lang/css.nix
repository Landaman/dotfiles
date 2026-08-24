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
      tailwindcss-language-server
      vscode-langservers-extracted
    ];

    lzePlugins = {
      nvim-treesitter.options = [
        {
          ensure_installed = [
            "css"
            "scss"
          ];
        }
      ];

      nvim-lspconfig.options = [
        {
          config.cssls = { };
          config.tailwindCSS = { };
        }
      ];

      conform-nvim.options = [
        {
          formatters_by_ft = {
            css = [ "web" ];
            less = [ "web" ];
            scss = [ "web" ];
          };
        }
      ];
    };
  };
}
