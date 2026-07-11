{ lib }:
rec {
  mkLuaExpression = code: { __lua = code; };
  isLuaExpression = v: builtins.typeOf v == "set" && v ? __lua;
  luaExpression = lib.types.addCheck (lib.types.attrsOf lib.types.str) (
    v: builtins.typeOf v == "set" && v ? __lua
  );
  luaModuleName =
    file:
    let
      name = lib.removeSuffix ".lua" (baseNameOf file.path);
      hash = builtins.substring 0 12 (builtins.hashString "sha256" (toString file.path));
    in
    "${name}_${hash}";
  requireLuaModuleFile =
    file:
    mkLuaExpression (
      "require(\"${luaModuleName file}\")"
      + lib.optionalString ((file.call or null) != null) ".${file.call}"
    );
  isLuaModuleFile = v: builtins.typeOf v == "set" && v ? path && builtins.typeOf v.path == "path";
}
