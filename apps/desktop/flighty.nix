{
  lib,
  _class,
  ...
}:
lib.optionalAttrs (_class == "darwin") {
  window.floatingApps = [ "com.flightyapp.flighty" ];

  homebrew.masApps = {
    flighty = 1358823008;
  };
}
