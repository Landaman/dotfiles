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
      vscode-langservers-extracted
    ];

    lzePlugins = {
      nvim-treesitter.options = [
        {
          ensure_installed = [
            "yaml"
          ];
        }
      ];

      conform-nvim.options = [
        {
          formatters_by_ft.yaml = [ "web" ];
        }
      ];
    };
  };
}
