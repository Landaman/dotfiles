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
  home-manager.users.${username}.programs.neovim.lzePlugins.conform-nvim = {
    enabled = luaUtils.mkLuaExpression "not vim.g.vscode";
    plugin = pkgs.vimPlugins.conform-nvim;
    module = "conform";
    onRequire = "conform";
    event = [ "BufWritePre" ];
    command = [ "ConformInfo" ];
    beforeAll = {
      path = ./conform.lua;
      call = "beforeAll";
    };
    options = [
      {
        format_on_save = { };
        default_format_opts = {
          lsp_format = "fallback";
          stop_after_first = true;
        };
      }
      {
        path = ./conform.lua;
        call = "opts";
      }
    ];
  };
}
