{
  lib,
  _class,
  ...
}:
lib.optionalAttrs (_class == "darwin") {
  homebrew.masApps = {
    colorslurp = 1287239339;
  };
}
