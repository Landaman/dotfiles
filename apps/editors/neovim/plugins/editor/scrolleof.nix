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
  home-manager.users.${username}.programs.neovim.lzePlugins.scrolleof = {
    enabled = luaUtils.mkLuaExpression "not vim.g.vscode";
    plugin = pkgs.vimUtils.buildVimPlugin {
      pname = "scrolleof";
      version = "1.3.1";
      src = pkgs.fetchFromGitHub {
        owner = "Aasim-A";
        repo = "scrollEOF.nvim";
        rev = "5f2d85ec3f5fb94dd8a4491264eba3594c60861d";
        hash = "sha256-1+RRX5ilETXk5UPFaIFJJus3QPFsJNnVKF0Z2YDfcG0=";
      };
      meta = {
        homepage = "https://github.com/Aasim-A/scrollEOF.nvim";
        license = lib.getLicenseFromSpdxId "MIT";
        hydraPlatforms = [ ];
      };
    };
    event = [
      "CursorMoved"
      "WinScrolled"
    ];
    module = "scrollEOF";
    options = [ { } ];
  };
}
