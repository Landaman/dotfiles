{ lib, ... }:

pluginSpec:

let
  luaUtils = import ../../../lib/lua.nix { inherit lib; };
  nixToLua = import ./nix-to-lua.nix { inherit lib; };

  fragmentsLua =
    value:
    let
      fragments = if builtins.typeOf value == "list" then value else [ value ];
      fragmentToLua =
        fragment:
        if luaUtils.isLuaModuleFile fragment then
          "(${nixToLua.toLuaValue fragment})()"
        else
          nixToLua.toLuaValue fragment;
    in
    "{ ${lib.concatStringsSep ", " (map fragmentToLua fragments)} }";

  normalizedOptsExtend = map (
    path: if builtins.typeOf path == "list" then path else [ path ]
  ) pluginSpec.optsExtend;

  mergeFragmentsRequire =
    (luaUtils.requireLuaModuleFile {
      path = ./config/plugin/lze/merge_options.lua;
    }).__lua;

  mergeFragmentsLua =
    {
      name,
      value,
      extend ? [ ],
    }:
    ''
      local ${name} = ${mergeFragmentsRequire}(
        ${fragmentsLua value},
        ${nixToLua.toLuaValue extend}
      )
    '';

  mergeOptionsLua =
    options:
    mergeFragmentsLua {
      name = "opts";
      value = options;
      extend = normalizedOptsExtend;
    };

  mergeKeysLua =
    keys:
    mergeFragmentsLua {
      name = "keys";
      value = keys;
      extend = [ [ ] ];
    };

  mergedKeys =
    if pluginSpec.keys == null then
      null
    else
      luaUtils.mkLuaExpression ''
        (function()
          ${mergeKeysLua pluginSpec.keys}
          return keys
        end)()
      '';

  callLuaModuleFile =
    value:
    if luaUtils.isLuaModuleFile value then
      luaUtils.mkLuaExpression ''
        function(...)
          local callback = ${nixToLua.toLuaValue value}
          return callback(...)
        end
      ''
    else
      value;

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
          keys = mergedKeys;
          colorscheme = pluginSpec.colorscheme;
          dep_of = pluginSpec.dependencyOf;
          on_plugin = pluginSpec.onPlugin;
          load = callLuaModuleFile pluginSpec.load;
          lazy = pluginSpec.lazy;
          beforeAll = callLuaModuleFile pluginSpec.beforeAll;
          before = callLuaModuleFile pluginSpec.before;
          after = afterLua;
          priority = pluginSpec.priority;
          on_require = pluginSpec.onRequire;
        };
      in
      nixToLua.toLuaValue fields;
}
