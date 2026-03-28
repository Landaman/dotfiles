{ lib, ... }:
{
  options.window = {
    floatingApps = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Apps that should always open in floating window mode";
    };
  };
}
