# Shared helper to process plugin specs into Lua expressions and plugin packages
{
  lib,
  pkgs,
  neovim,
}:

let
  lzeGenerate = import ./lze-generate.nix { inherit lib pkgs; };
  luaUtils = import ../../../lib/lua.nix { inherit lib; };
  nixToLua = import ./nix-to-lua.nix { inherit lib; };
  pluginSpecs = neovim.lzePlugins or { };

  processedPluginSpecs = (lib.mapAttrsToList (_: spec: lzeGenerate spec) pluginSpecs);

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
      lib.filterAttrs (_: value: value != null) (neovim.vimG or { })
    )
  );

  extraConfigFiles = neovim.extraConfigFiles or [ ];
  pluginLuaModuleFiles =
    let
      collect =
        value:
        let
          type = builtins.typeOf value;
        in
        if luaUtils.isLuaModuleFile value then
          [ value ]
        else if lib.isDerivation value then
          [ ]
        else if type == "list" then
          lib.concatMap collect value
        else if type == "set" then
          lib.concatMap collect (lib.attrValues (removeAttrs value [ "plugin" ]))
        else
          [ ];
    in
    collect pluginSpecs;
  # Include the exact merge helper referenced by generated Lua so its path hash matches the module name
  linkedLuaFiles =
    extraConfigFiles
    ++ pluginLuaModuleFiles
    ++ [
      { path = ./config/plugin/lze/merge_options.lua; }
    ];

  extraConfigRequires = lib.concatStringsSep "\n" (
    lib.map (file: (luaUtils.requireLuaModuleFile file).__lua) extraConfigFiles
  );

  extraConfigXdgFiles = lib.listToAttrs (
    lib.map (file: {
      name = "nvim/lua/${luaUtils.luaModuleName file}.lua";
      value.source = file.path;
    }) linkedLuaFiles
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
  inherit initLua allPlugins extraConfigXdgFiles;
}
