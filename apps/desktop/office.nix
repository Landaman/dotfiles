{
  pkgs,
  lib,
  ...
}:
{
  homebrew.masApps = lib.mkIf pkgs.stdenv.isDarwin {
    keynote = 409183694;
    pages = 409201541;
    numbers = 409203825;
  };
}
