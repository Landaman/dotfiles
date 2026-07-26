{
  config,
  pkgs,
  ...
}:

let
  username = config.user.username;
in
{
  home-manager.users.${username}.programs.neovim.lzePlugins.nvim-web-devicons = {
    plugin = pkgs.vimPlugins.nvim-web-devicons;
  };
}
