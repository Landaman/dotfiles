{
  config,
  lib,
  pkgs,
  catppuccin,
  homeManager,
  _class,
  ...
}:
let
  username = config.user.username;
in
{
  imports = [
    ../modules/user.nix
    homeManager.${if _class == "darwin" then "darwinModules" else "nixosModules"}.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    sharedModules = [
      catppuccin.homeModules.catppuccin
    ];

    users.${username} = {
      programs.home-manager.enable = true;
      targets.darwin = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
        copyApps.enable = true;
        linkApps.enable = false;
      };
    };
  };
}
