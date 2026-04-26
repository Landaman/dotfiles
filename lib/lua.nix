{ lib }:
{
  mkLuaExpression = code: { __lua = code; };
  isLuaExpression = v: v ? __lua;
  luaExpression = lib.types.submodule {
    options = {
      __lua = lib.mkOption { type = lib.types.str; };
    };
  };
}
