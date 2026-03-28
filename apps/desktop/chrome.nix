{
  config,
  ...
}:
let
  username = config.user.username;
in
{
  home-manager.users.${username} = {
    programs.google-chrome = {
      enable = true;
    };

    home.file."Library/Application Support/Google/Chrome/External Extensions/blipmdconlkpinefehnmjammfjpmpbjk.json".text =
      ''
        {
          "external_update_url": "https://clients2.google.com/service/update2/crx"
        }
      '';
  };
}
