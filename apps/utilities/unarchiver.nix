{
  lib,
  _class,
  ...
}:
lib.optionalAttrs (_class == "darwin") {
  homebrew.masApps = {
    "The Unarchiver" = 425424353;
  };
}
