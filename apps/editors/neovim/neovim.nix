{
  config,
  lib,
  pkgs,
  ...
}:

let
  username = config.user.username;

  lzeGenerate = import ./lze-generate.nix { inherit lib pkgs; };
  nixToLua = import ./nix-to-lua.nix { inherit lib; };

  processedPluginSpecs = (
    lib.mapAttrsToList (_: spec: lzeGenerate spec) (
      config.home-manager.users.${username}.programs.neovim.lzePlugins or { }
    )
  );

  lzePlugins = lib.filter (package: package != null) (
    lib.map (spec: spec.package) processedPluginSpecs
  );
  allPlugins = [
    # Load lze on startup to let it load everything else
    {
      plugin = pkgs.vimPlugins.lze;
      optional = false;
    }
  ]
  ++ lzePlugins;

  luaSpecStrings = lib.concatStringsSep "," (
    lib.filter (s: s != null) (lib.map (spec: spec.luaSpec) processedPluginSpecs)
  );
  setupLzeLuaExpression =
    if luaSpecStrings == "" then "" else "require(\"lze\").load({${luaSpecStrings}})";

  vimGAssignments = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (key: value: "vim.g.${key} = ${nixToLua.toLuaValue value}") (
      lib.filterAttrs (_: value: value != null) (
        config.home-manager.users.${username}.programs.neovim.vimG or { }
      )
    )
  );

  extraConfigFiles = config.home-manager.users.${username}.programs.neovim.extraConfigFiles or [ ];

  extraConfigRequires = lib.concatStringsSep "\n" (
    lib.map (file: "require '${file.module}'") extraConfigFiles
  );

  extraConfigXdgFiles = lib.listToAttrs (
    lib.map (file: {
      name = "nvim/lua/${file.module}.lua";
      value.source = file.path;
    }) extraConfigFiles
  );

  initLua = lib.concatStringsSep "\n" (
    lib.filter (lua: lua != "") [
      "vim.g.mapleader = ' '"
      "vim.g.maplocalleader = ' '"
      vimGAssignments
      extraConfigRequires
      "vim.loader.enable()" # Enable the experimental loader for performance
      setupLzeLuaExpression
    ]
  );
in
{
  home-manager.users.${username} = {
    xdg.configFile = extraConfigXdgFiles;

    programs.neovim = {
      enable = true;
      defaultEditor = true;
      extraConfigFiles = lib.mkBefore [
        { path = ./config/options.lua; }
        { path = ./config/keymaps.lua; }
        { path = ./config/diagnostics.lua; }
      ];
      extraPackages = with pkgs; [
        tree-sitter
      ];
      plugins = allPlugins;
      initLua = initLua;
    };
  };
}
