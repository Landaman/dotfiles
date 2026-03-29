{
  pkgs,
  lib,
  ...
}:
{
  homebrew.masApps = lib.mkIf pkgs.stdenv.isDarwin {
    "The Unarchiver" = 425424353;
  };
}
