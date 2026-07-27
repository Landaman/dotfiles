{
  config,
  lib,
  pkgs,
  ...
}:

let
  luaUtils = import ../../../../../lib/lua.nix { inherit lib; };
  username = config.user.username;
in
{
  home-manager.users.${username}.programs.neovim.lzePlugins = {
    remote-nvim-nvim = {
      enabled = luaUtils.mkLuaExpression "not vim.g.vscode";
      plugin = pkgs.vimPlugins.remote-nvim-nvim;
      module = "remote-nvim";
      command = [
        "RemoteStart"
        "RemoteStop"
        "RemoteInfo"
        "RemoteCleanup"
        "RemoteConfigDel"
        "RemoteLog"
      ];
      options = { };
    };

    plenary-nvim.dependencyOf = [ "remote-nvim.nvim" ];

    nui-nvim = {
      plugin = pkgs.vimPlugins.nui-nvim;
      dependencyOf = [ "remote-nvim.nvim" ];
    };
  };
}
