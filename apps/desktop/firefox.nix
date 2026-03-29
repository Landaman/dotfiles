{
  config,
  ...
}:
{
  home-manager.users.${config.user.username}.programs.firefox = {
    enable = true;
  };
}
