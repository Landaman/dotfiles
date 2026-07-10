{ lib, ... }:

let
  luaUtils = import ../../../lib/lua.nix { inherit lib; };
in
rec {
  toLuaValue =
    value:
    let
      type = builtins.typeOf value;
    in
    if value == null then
      null # Callers should use a luaExpression of nil to evaluate this.
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
          lib.mapAttrsToList (
            k: v:
            if k == "" then
              if builtins.typeOf v == "list" then lib.concatStringsSep ", " (map toLuaValue v) else toLuaValue v
            else
              "${k} = ${toLuaValue v}"
          ) value
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
}
