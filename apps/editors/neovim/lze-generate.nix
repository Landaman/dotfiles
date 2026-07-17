{ lib, ... }:

pluginSpec:

let
  luaUtils = import ../../../lib/lua.nix { inherit lib; };
  nixToLua = import ./nix-to-lua.nix { inherit lib; };

  optsLua =
    options:
    let
      fragments = if builtins.typeOf options == "list" then options else [ options ];
      optsFragmentToLua =
        fragment:
        if luaUtils.isLuaModuleFile fragment then
          "(${nixToLua.toLuaValue fragment})()"
        else
          nixToLua.toLuaValue fragment;
    in
    "{ ${lib.concatStringsSep ", " (map optsFragmentToLua fragments)} }";

  normalizedOptsExtend = map (
    path: if builtins.typeOf path == "list" then path else [ path ]
  ) pluginSpec.optsExtend;

  mergeOptionsRequire =
    (luaUtils.requireLuaModuleFile {
      path = ./config/plugin/lze/merge_options.lua;
    }).__lua;

  mergeOptionsLua = options: ''
    local opts = ${mergeOptionsRequire}(
      ${optsLua options},
      ${nixToLua.toLuaValue normalizedOptsExtend}
    )
  '';

  afterLua =
    if pluginSpec.options != null && pluginSpec.after != null then
      luaUtils.mkLuaExpression ''
        function()
          ${mergeOptionsLua pluginSpec.options}
          local after = ${nixToLua.toLuaValue pluginSpec.after}
          after(opts)
        end
      ''
    else if pluginSpec.options != null && pluginSpec.module != null then
      luaUtils.mkLuaExpression ''
        function()
          ${mergeOptionsLua pluginSpec.options}
          require("${pluginSpec.module}").setup(opts)
        end
      ''
    else if pluginSpec.after != null && luaUtils.isLuaModuleFile pluginSpec.after then
      luaUtils.mkLuaExpression ''
        function()
          local after = ${nixToLua.toLuaValue pluginSpec.after}
          after()
        end
      ''
    else
      pluginSpec.after;

in
{
  package = {
    plugin = pluginSpec.plugin;
    optional = true;
  };

  luaSpec =
    if pluginSpec.enabled == false then
      null # Can trivially skip the step
    else
      let
        fields = lib.filterAttrs (k: v: v != null) {
          "" = pluginSpec.plugin.pname; # Has to be first with no key
          enabled = if pluginSpec.enabled == true then null else pluginSpec.enabled; # Don't both passing in true/false, only pass in a Lua expression
          event = pluginSpec.event;
          cmd = pluginSpec.command;
          ft = pluginSpec.filetype;
          keys = pluginSpec.keys;
          colorscheme = pluginSpec.colorscheme;
          dep_of = pluginSpec.dependencyOf;
          on_plugin = pluginSpec.onPlugin;
          load = pluginSpec.load;
          beforeAll = pluginSpec.beforeAll;
          before = pluginSpec.before;
          after = afterLua;
          on_require = pluginSpec.onRequire;
        };
      in
      nixToLua.toLuaValue fields;
}
