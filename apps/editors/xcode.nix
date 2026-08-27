{ pkgs, lib, ... }:
{
  homebrew.masApps = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    xcode = 497799835;
  };
}
