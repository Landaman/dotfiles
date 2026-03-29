{
  pkgs,
  lib,
  ...
}:
{
  homebrew.masApps = lib.mkIf pkgs.stdenv.isDarwin {
    goodnotes = 1444383602;
  };
}
