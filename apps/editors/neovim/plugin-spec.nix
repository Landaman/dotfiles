{ lib, pkgs, ... }:

let
  types = lib.types;

  strOrList = types.either types.str (types.listOf types.str);

  lua = types.str;

  boolOrLua = types.oneOf [
    types.bool
    lua
  ];

  eventType = types.oneOf [
    types.str
    (types.listOf types.str)
    (types.submodule {
      options = {
        event = lib.mkOption { type = strOrList; };
        pattern = lib.mkOption { type = strOrList; };
      };
    })
  ];

in
{
  options.programs.neovim.lzePlugins = lib.mkOption {
    type = types.attrsOf (
      types.submodule (
        { config, ... }:
        {
          options = {
            enabled = lib.mkOption {
              type = boolOrLua;
              default = true;
              description = "Whther to enable this plugin. Can be a boolean or a Lua expression that evaluates to a boolean.";
            };

            # Copied from the HM definition
            plugin = lib.mkPackageOption pkgs.vimPlugins "plugin" {
              example = "pkgs.vimPlugins.nvim-treesitter";
              pkgsText = "pkgs.vimPlugins";
            };

            # Lua module name (independent of package name)
            module = lib.mkOption {
              type = types.nullOr types.str;
              default = config.plugin.name;
              description = ''
                Lua module used for require(). Defaults to the package name if unset.
              '';
            };

            # Options to use when automatically creating an after function to call setup
            options = lib.mkOption {
              type = types.nullOr types.attrs;
              default = null;
              description = ''
                Options passed to require('<module>').setup(...). Mutually exclusive with `after`.
              '';
            };

            beforeAll = lib.mkOption {
              type = types.nullOr lua;
              default = null;
              description = "Always executed upon calling require('lze').load(spec) before any plugin specs from that call are triggered to be loaded.";
            };

            before = lib.mkOption {
              type = types.nullOr lua;
              default = null;
              description = "Executed before the plugin is loaded.";
            };

            after = lib.mkOption {
              type = types.nullOr lua;
              default = null;
              description = "Executed after the plgugin is loaded. Mutually exclusive with `options`.";
            };

            event = lib.mkOption {
              type = types.nullOr eventType;
              default = null;
              description = "Lazy-load on event. Events can be specified as BufEnter or with a pattern like BufEnter *.lua.";
            };

            cmd = lib.mkOption {
              type = types.nullOr strOrList;
              default = null;
              description = "Lazy-load on command.";
            };

            ft = lib.mkOption {
              type = types.nullOr strOrList;
              default = null;
              description = "Lazy-load on filetype.";
            };

            keys = lib.mkOption {
              type = types.nullOr (types.listOf types.attrs);
              default = null;
              description = "Lazy-load on key mapping.";
            };

            colorscheme = lib.mkOption {
              type = types.nullOr strOrList;
              default = null;
              description = "Lazy-load on colorscheme.";
            };

            dep_of = lib.mkOption {
              type = types.nullOr strOrList;
              default = null;
              description = "Lazy-load before another plugin but after its before hook. Accepts a plugin name or a list of plugin names.";
            };

            on_plugin = lib.mkOption {
              type = types.nullOr strOrList;
              default = null;
              description = "Lazy-load after another plugin but before its after hook. Accepts a plugin name or a list of plugin names.";
            };
          };

          config = {
            assertions = [
              {
                assertion = !(config.options != null && config.after != null);
                message = "Cannot use both `options` and `after` for plugin ${config.name}";
              }
            ];
          };
        }
      )
    );

    default = { };
    description = ''
      lze plugin specifications for Neovim.
      This automatically injects plugins into the neovim configuraiton and sets up lazy loading in Lua.
      Keys are meaningless except to merge specs together.
    '';
  };
}
