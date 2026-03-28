{
  config,
  ...
}:
let
  username = config.user.username;
in
{
  home-manager.users.${username}.programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      merge.tool = "nvimdiff";
      merge.conflictstyle = "zdiff3";
      user = {
        email = "49083526+Landaman@users.noreply.github.com";
        name = "Ian Wright";
      };
    };
  };
}
