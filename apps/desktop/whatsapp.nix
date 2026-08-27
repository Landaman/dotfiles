{
  pkgs,
  lib,
  ...
}:
{
  homebrew.masApps = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    whatsapp = 310633997;
  };
}
