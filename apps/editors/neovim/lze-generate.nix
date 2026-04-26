{ lib, ... }:

pluginSpec:

let
  luaUtils = import ../../../lib/lua.nix { inherit lib; };

  toLuaValue =
    value:
    let
      type = builtins.typeOf value;
    in
    if value == null then
      null # Callers should use a luaExpression of nil to evaluate this. This one should be basically JS undefined AKA don't set this value at all
    else if luaUtils.isLuaExpression value then
      value.__lua
    else if type == "bool" then
      lib.boolToString value
    else if type == "int" || type == "float" then
      toString value
    else if type == "string" then
      ''"${value}"''
    else if type == "list" then
      "{ ${lib.concatStringsSep ", " (map toLuaValue value)} }"
    else if type == "set" then
      "{ ${
        lib.concatStringsSep ", " (
          lib.mapAttrsToList (k: v: if k != "" then "${k} = ${toLuaValue v}" else (toLuaValue v)) value
        )
      } }"
    else
      "";

  toLuaTable =
    attrs:
    let
      filtered = lib.filterAttrs (k: v: v != null && v != "") attrs;
    in
    toLuaValue filtered;

  pluginName = pluginSpec.module; # Derived from the plugin package name if required

  afterLua =
    let
      opts = pluginSpec.options;
    in
    if opts != null then
      "function() require(\"${pluginName}\").setup(${toLuaTable opts}) end"
    else
      toLuaValue pluginSpec.after;

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
          "" = pluginName; # Has to be first with no key
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
      toLuaValue fields;
}
