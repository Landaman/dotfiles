{
  lib,
  _class,
  ...
}:
lib.optionalAttrs (_class == "darwin") {
  window.floatingApps = [ "net.whatsapp.WhatsApp" ];

  homebrew.masApps = {
    whatsapp = 310633997;
  };
}
