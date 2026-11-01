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
  config.home-manager.users.${username} = {
    home.packages = lib.optionals (
      pkgs.stdenv.hostPlatform.isDarwin && pkgs.stdenv.hostPlatform.isAarch64
    ) [ pkgs.herdr-app ];

    programs.herdr = {
      enable = true;
      package = pkgs.herdr;
      settings = {
        onboarding = false;
        keys.prefix = "ctrl+a";
        ui = {
          prompt_new_tab_name = false;
          toast.delivery = "terminal";
        };
      };
    };
  };
}
