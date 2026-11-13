{
  lib,
  _class,
  ...
}:
lib.optionalAttrs (_class == "darwin") {
  homebrew.masApps = {
    adgaurd = 1440147259;
  };
}
