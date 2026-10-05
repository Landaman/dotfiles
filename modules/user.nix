{ config, lib, ... }:
{
  options.user.username = lib.mkOption {
    type = lib.types.str;
    description = "The user's username";
  };

  config = {
    system.primaryUser = config.user.username;
    # Without this, home-manager looses its mind
    users.users.${config.user.username}.home = "/Users/${config.user.username}";
  };
}
