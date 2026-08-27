{ pkgs, lib, ... }:
{
  homebrew.masApps = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    "Hidden Bar" = 1452453066;
  };
}
