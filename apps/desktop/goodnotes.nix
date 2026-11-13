{
  lib,
  _class,
  ...
}:
lib.optionalAttrs (_class == "darwin") {
  homebrew.masApps = {
    goodnotes = 1444383602;
  };
}
