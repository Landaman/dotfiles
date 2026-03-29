{ pkgs, lib, ... }:
{
  homebrew.masApps = lib.mkIf pkgs.stdenv.isDarwin {
    "Hidden Bar" = 1452453066;
  };
}
