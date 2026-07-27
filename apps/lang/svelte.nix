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
      svelte-language-server
    ];

    lzePlugins = {
      nvim-treesitter.options = [
        {
          ensure_installed = [ "svelte" ];
        }
      ];

      nvim-lspconfig.options = [
        {
          config.svelte = { };
        }
      ];

      conform-nvim.options = [
        {
          formatters_by_ft.svelte = [ "prettierd" ];
        }
      ];

      nvim-dap.options = [
        {
          adapters = [
            {
              path = ./svelte.lua;
            }
          ];
        }
      ];
    };
  };
}
