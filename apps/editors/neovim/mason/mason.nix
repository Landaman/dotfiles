{
  config,
  lib,
  pkgs,
  ...
}:

let
  neovim = config.programs.neovim;
in

{
  options.programs.neovim.mason = {
    packages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Mason packages to install in standalone mode";
    };
    registries = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional Mason registries to setup in standalone mode";
    };
    registryPackages = lib.mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      default = { };
      description = "Additional Mason package definitions for standalone mode";
    };
  };

  # Configure Mason only for exported Neovim instances
  config = lib.mkIf neovim.standalone {
    programs.neovim.lzePlugins.mason = {
      plugin = pkgs.vimPlugins.mason-nvim;
      lazy = false;
      priority = 1000; # Make tools available before other startup plugins are configured
      options = [
        {
          packages = lib.unique neovim.mason.packages;
          registry_packages = lib.mapAttrs (
            name: spec: spec // { inherit name; }
          ) neovim.mason.registryPackages;
          registries = lib.unique (
            neovim.mason.registries
            ++ [
              "lua:dotfiles-mason-registry"
              "github:mason-org/mason-registry"
            ]
          );
        }
      ];
      after = {
        path = ./mason.lua;
      };
    };
  };
}
