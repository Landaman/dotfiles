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
      version = "1.2.10";
      src = pkgs.fetchFromGitHub {
        owner = "Aasim-A";
        repo = "scrollEOF.nvim";
        rev = "e462b9a07b8166c3e8011f1dcbc6bf68b67cd8d7";
        hash = "sha256-2ZJV23CZ8B3x4DPHGuWnq84Jp3gLvyCARuyqtrZEOos=";
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
