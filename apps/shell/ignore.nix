{
  config,
  lib,
  ...
}:
let
  username = config.user.username;
in
{
  home-manager.users.${username}.home.file.".ignore".text =
    lib.concatStringsSep "\n" config.files.ignoreGlobs;
}
