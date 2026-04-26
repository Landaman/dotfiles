{ lib, ... }:

pluginSpec:

let
  toLuaValue =
    value:
    let
      type = builtins.typeOf value;
    in
    if value == null then
      null # Callers should use a luaExpression of nil to evaluate this. This one should be basically JS undefined AKA don't set this value at all
    else if lib.isLuaExpression value then
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
      "{ ${lib.concatStringsSep ", " (lib.mapAttrsToList (k: v: "${k} = ${toLuaValue v}") value)} }"
    else
      "";

  toLuaTable =
    attrs:
    let
      filtered = lib.filterAttrs (k: v: v != null && v != "") attrs;
    in
    "{ ${lib.concatStringsSep ", " (lib.mapAttrsToList (k: v: "${k} = ${toLuaValue v}") filtered)} }";

  pluginName = pluginSpec.module;

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
          enabled = if pluginSpec.enabled == true then null else toLuaValue pluginSpec.enabled; # Don't both passing in true/false, only pass in a Lua expression
          event = toLuaValue pluginSpec.event;
          cmd = toLuaValue pluginSpec.command;
          ft = toLuaValue pluginSpec.filetype;
          keys = toLuaValue pluginSpec.keys;
          colorscheme = toLuaValue pluginSpec.colorscheme;
          dep_of = toLuaValue pluginSpec.dependencyOf;
          on_plugin = toLuaValue pluginSpec.onPlugin;
          beforeAll = toLuaValue pluginSpec.beforeAll;
          before = toLuaValue pluginSpec.before;
          after = afterLua;
        };
        luaPairs = lib.mapAttrsToList (k: v: "${k} = ${v}") fields;
      in
      toLuaValue luaPairs;
}
