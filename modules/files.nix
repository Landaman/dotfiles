{ lib, ... }:
{
  options.files = {
    neverShowGlobs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Globs that should never be shown in file finders";
    };

    ignoreGlobs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Globs for .ignore file";
    };
  };
}
