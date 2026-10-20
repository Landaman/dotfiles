{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.user.username = lib.mkOption {
    type = lib.types.str;
    description = "The user's username";
  };

  config = {
    # Without this, home-manager looses its mind
    users.users.${config.user.username}.home =
      if pkgs.stdenv.hostPlatform.isDarwin then
        "/Users/${config.user.username}"
      else
        "/home/${config.user.username}";
  };
}
