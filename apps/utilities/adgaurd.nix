{
  pkgs,
  lib,
  ...
}:
{
  homebrew.masApps = lib.mkIf pkgs.stdenv.isDarwin {
    adgaurd = 1440147259;
  };
}
