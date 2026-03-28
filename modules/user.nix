{ lib, ... }:
{
  options.user.username = lib.mkOption {
    type = lib.types.str;
    description = "The user's username";
  };
}
