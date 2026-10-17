{ config, catppuccin, ... }:
let
  username = config.user.username;
in
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    sharedModules = [
      catppuccin.homeModules.catppuccin
    ];

    users.${username} = {
      imports = [
        ./home.nix
      ];
      home = {
        inherit username;
        homeDirectory = config.users.users.${username}.home;
      };
      targets.darwin = {
        copyApps.enable = true;
        linkApps.enable = false;
      };
    };
  };
}
