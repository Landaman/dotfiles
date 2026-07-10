{ lib, ... }:

pluginSpec:

let
  luaUtils = import ../../../lib/lua.nix { inherit lib; };
  nixToLua = import ./nix-to-lua.nix { inherit lib; };

  afterLua =
    let
      opts = pluginSpec.options;
    in
    if opts != null then
      luaUtils.mkLuaExpression "function() require(\"${pluginSpec.module}\").setup(${nixToLua.toLuaTable opts}) end"
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
          beforeAll = pluginSpec.beforeAll;
          before = pluginSpec.before;
          after = afterLua;
        };
      in
      nixToLua.toLuaValue fields;
}
