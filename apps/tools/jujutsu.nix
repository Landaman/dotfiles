{
  config,
  ...
}:
let
  username = config.user.username;
in
{
  home-manager.users.${username}.programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Ian Wright";
      };
    };
  };
}
