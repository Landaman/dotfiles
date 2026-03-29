{
  config,
  pkgs,
  lib,
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

    home.file = {
      "Library/Application Support/Google/Chrome/External Extensions/blipmdconlkpinefehnmjammfjpmpbjk.json" =
        lib.mkIf pkgs.stdenv.isDarwin {
          text = ''
            {
              "external_update_url": "https://clients2.google.com/service/update2/crx"
            }
          '';
        };
      ".config/google-chrome/Default/Extensions/blipmdconlkpinefehnmjammfjpmpbjk.json" =
        lib.mkIf (!pkgs.stdenv.isDarwin)
          {
            text = ''
              {
                "external_update_url": "https://clients2.google.com/service/update2/crx"
              }
            '';
          };
    };
  };
}
