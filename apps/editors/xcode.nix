{ pkgs, lib, ... }:
{
  homebrew.masApps = lib.mkIf pkgs.stdenv.isDarwin {
    xcode = 497799835;
  };
}
