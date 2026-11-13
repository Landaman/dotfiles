{ lib, _class, ... }:
lib.optionalAttrs (_class == "darwin") {
  homebrew.casks = [ "logi-options+" ];
}
