{ lib, ... }:
{
  options.files = {
    neverShowGlobs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Globs that should never be shown in file finders";
    };

    ignoreGlobs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Globs for .ignore file";
    };
  };

  config.files.neverShowGlobs = [
    ".git/"
    ".DS_Store"
  ];

  config.files.ignoreGlobs = [
    "!.env*"
    "!.vscode/"
  ];
}
