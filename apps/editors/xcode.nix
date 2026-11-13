{ lib, _class, ... }:
lib.optionalAttrs (_class == "darwin") {
  homebrew.masApps = {
    xcode = 497799835;
  };
}
