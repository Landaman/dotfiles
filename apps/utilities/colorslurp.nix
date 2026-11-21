{
  lib,
  _class,
  ...
}:
lib.optionalAttrs (_class == "darwin") {
  menuBar.hiddenApps = [ "com.IdeaPunch.ColorSlurp" ];

  homebrew.masApps = {
    colorslurp = 1287239339;
  };
}
