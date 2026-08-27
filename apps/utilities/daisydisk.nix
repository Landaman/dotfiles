{
  pkgs,
  lib,
  ...
}:
{
  homebrew.masApps = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    daisydisk = 411643860;
  };
}
