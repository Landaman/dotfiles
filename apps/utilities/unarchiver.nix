{
  pkgs,
  lib,
  ...
}:
{
  homebrew.masApps = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    "The Unarchiver" = 425424353;
  };
}
