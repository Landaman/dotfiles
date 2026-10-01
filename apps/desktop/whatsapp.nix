{
  pkgs,
  lib,
  ...
}:
{
  window.floatingApps = [ "net.whatsapp.WhatsApp" ];

  homebrew.masApps = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    whatsapp = 310633997;
  };
}
