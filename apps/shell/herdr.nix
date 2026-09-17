{
  config,
  lib,
  pkgs,
  ...
}:
let
  username = config.user.username;
in
{
  options.herdr.theme = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = "The theme to use for Herdr";
  };

  config.home-manager.users.${username} = {
    home.packages = [ pkgs.herdr ];

    xdg.configFile."herdr/config.toml".text = ''
      onboarding = false

      [keys]
      prefix = "ctrl+a"

      [ui]
      prompt_new_tab_name = false

      [ui.toast]
      delivery = "terminal"

      [theme]
      ${lib.optionalString (config.herdr.theme != null) ''name = "${config.herdr.theme}"''}
    '';
  };
}
