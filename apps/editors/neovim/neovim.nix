{
  config,
  lib,
  pkgs,
  homeManager,
  ...
}:

let
  username = config.user.username;

  generated = import ./generate-config.nix {
    inherit lib pkgs;
    neovim = config.home-manager.users.${username}.programs.neovim;
  };

in
{
  home-manager.users.${username} = {
    xdg.configFile = generated.extraConfigXdgFiles;

    # Nix plugin updates can preserve size and mtime, leaving vim.loader's bytecode cache stale
    home.activation.clearNeovimLuaCache = homeManager.lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      run rm -rf -- ${lib.escapeShellArg "${config.home-manager.users.${username}.xdg.cacheHome}/nvim/luac"}
    '';

    programs.neovim = {
      enable = true;
      defaultEditor = true;
      extraConfigFiles = lib.mkBefore [
        { path = ./config/options.lua; }
        { path = ./config/keymaps.lua; }
        { path = ./config/diagnostics.lua; }
      ];
      mason.packages = [ "tree-sitter-cli" ];
      extraPackages = with pkgs; [
        tree-sitter
        gcc # Needed for treesitter compilation at runtime
      ];
      plugins = generated.allPlugins;
      initLua = generated.initLua;
    };
  };
}
