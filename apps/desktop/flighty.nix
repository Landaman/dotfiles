{
  pkgs,
  lib,
  ...
}:
{
  window.floatingApps = [ "com.flightyapp.flighty" ];

  homebrew.masApps = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    flighty = 1358823008;
  };
}
