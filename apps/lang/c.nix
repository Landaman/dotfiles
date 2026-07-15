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
}
