{
  lib,
  config,
  pkgs,
  ...
}:

let
  username = config.user.username;

  luaUtils = import ../../../lib/lua.nix { inherit lib; };
  luaExpression = luaUtils.luaExpression;

  listOfStrOrLuaExpression = lib.types.oneOf [
    lib.types.str
    (lib.types.listOf lib.types.str)
    luaExpression
  ];
  boolOrLuaExpression = lib.types.oneOf [
    lib.types.bool
    luaExpression
  ];
  luaHook = lib.types.either luaExpression luaModuleFileType;

  optsExtendPath = lib.types.either lib.types.str (lib.types.listOf lib.types.str);
  luaModuleFileType = lib.types.submodule {
    options = {
      path = lib.mkOption {
        type = lib.types.path;
        description = "Lua file to link into the Neovim Lua path";
      };

      call = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Optional member function to select from the required Lua module.";
      };
    };
  };
  optionsFragment = lib.types.oneOf [
    lib.types.attrs
    luaExpression
    luaModuleFileType
  ];
  optionsFragments = lib.types.either optionsFragment (lib.types.listOf optionsFragment);

in
{
  home-manager.users.${username}.imports = [
    {
      options = {
        programs.neovim = {
          vimG = lib.mkOption {
            type = lib.types.attrsOf lib.types.anything;
            default = { };
            description = ''
              Values assigned to vim.g before lazy plugin specs are loaded.
              Values are converted from Nix to Lua using the same conversion as lze plugin specs.
            '';
          };

          extraConfigFiles = lib.mkOption {
            type = lib.types.listOf luaModuleFileType;
            default = [ ];
            description = ''
              Startup Lua config files to link into the Neovim Lua path and require from init.lua.
              Do not use this for lazy plugin setup modules. Lua files referenced from
              lzePlugins are linked separately without being required at startup.
            '';
          };

          lzePlugins = lib.mkOption {
            type = lib.types.attrsOf (
              lib.types.submodule (
                { config, ... }:
                {
                  options = {
                    enabled = lib.mkOption {
                      type = boolOrLuaExpression;
                      default = true;
                      description = "Whether to enable this plugin. Can be a boolean or a Lua expression.";
                    };

                    # Copied from the HM definition
                    plugin = lib.mkPackageOption pkgs.vimPlugins "plugin" {
                      example = "pkgs.vimPlugins.nvim-treesitter";
                      pkgsText = "pkgs.vimPlugins";
                    };

                    # Lua module name (independent of package name)
                    module = lib.mkOption {
                      type = lib.types.nullOr lib.types.str;
                      default = config.plugin.pname;
                      description = ''
                        Lua module used for automatic setup with require('<module>').setup(opts).
                        Defaults to the plugin package name if unset.
                        Automatic setup is used when `options` is set and `after` is unset.
                      '';
                    };

                    # Options to use when automatically creating an after function to call setup
                    options = lib.mkOption {
                      type = lib.types.nullOr optionsFragments;
                      default = null;
                      description = ''
                        Options fragments merged at runtime. Fragments can be Nix attrsets,
                        or raw Lua expressions returning tables.
                      '';
                    };

                    optsExtend = lib.mkOption {
                      type = lib.types.listOf optsExtendPath;
                      default = [ ];
                      description = ''
                        Dotted option paths whose list-like values should be appended while merging.
                      '';
                    };

                    load = lib.mkOption {
                      type = lib.types.nullOr luaHook;
                      default = null;
                      description = "Can be used to override the vim.g.lze.load(name) function for an individual plugin. (default is vim.cmd.packadd(name))";
                    };

                    lazy = lib.mkOption {
                      type = lib.types.nullOr lib.types.bool;
                      default = null;
                      description = "Using a handler's field sets this automatically, but you can set this manually as well";
                    };

                    beforeAll = lib.mkOption {
                      type = lib.types.nullOr luaHook;
                      default = null;
                      description = "Always executed upon calling require('lze').load(spec) before any plugin specs from that call are triggered to be loaded.";
                    };

                    before = lib.mkOption {
                      type = lib.types.nullOr luaHook;
                      default = null;
                      description = "Executed before the plugin is loaded.";
                    };

                    after = lib.mkOption {
                      type = lib.types.nullOr luaHook;
                      default = null;
                      description = "Executed after the plugin is loaded. Called with merged options when options are set.";
                    };

                    priority = lib.mkOption {
                      type = lib.types.nullOr lib.types.int;
                      default = null;
                      description = "Only useful for start plugins (not lazy-loaded) to force loading certain plugins first. Default priority is 50, or the value of vim.g.lze.default_priority.";
                    };

                    event = lib.mkOption {
                      type = lib.types.nullOr listOfStrOrLuaExpression;
                      default = null;
                      description = "Lazy-load on event. Events can be specified as BufEnter or with a pattern like BufEnter *.lua.";
                    };

                    command = lib.mkOption {
                      type = lib.types.nullOr listOfStrOrLuaExpression;
                      default = null;
                      description = "Lazy-load on command.";
                    };

                    filetype = lib.mkOption {
                      type = lib.types.nullOr listOfStrOrLuaExpression;
                      default = null;
                      description = "Lazy-load on filetype.";
                    };

                    keys = lib.mkOption {
                      type = lib.types.nullOr (lib.types.listOf lib.types.attrs);
                      default = null;
                      description = "Lazy-load on key mapping.";
                    };

                    colorscheme = lib.mkOption {
                      type = lib.types.nullOr listOfStrOrLuaExpression;
                      default = null;
                      description = "Lazy-load on colorscheme.";
                    };

                    dependencyOf = lib.mkOption {
                      type = lib.types.nullOr listOfStrOrLuaExpression;
                      default = null;
                      description = "Lazy-load before another plugin but after its before hook. Accepts a plugin name or a list of plugin names.";
                    };

                    onPlugin = lib.mkOption {
                      type = lib.types.nullOr listOfStrOrLuaExpression;
                      default = null;
                      description = "Lazy-load after another plugin but before its after hook. Accepts a plugin name or a list of plugin names.";
                    };

                    onRequire = lib.mkOption {
                      type = lib.types.nullOr listOfStrOrLuaExpression;
                      default = null;
                      description = "Accepts a top-level lua module name or a list of top-level lua module names. Will load when any submodule of those listed is required";
                    };
                  };
                }
              )
            );

            default = { };
            description = ''
              lze plugin specifications for Neovim.
              This automatically injects plugins into the neovim configuration and sets up lazy loading in Lua.
              Keys are meaningless except to merge specs together.
            '';
          };
        };
      };
    }
  ];
  assertions = [
    {
      assertion = lib.all (
        plugin: plugin.options == null || plugin.after != null || plugin.module != null
      ) (lib.attrValues config.home-manager.users.${config.user.username}.programs.neovim.lzePlugins);

      message = "lzePlugins: each plugin with `options` must define `after` or `module`";
    }
  ];
}
