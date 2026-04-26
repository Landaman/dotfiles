{ lib, pkgs, ... }:

let
  strOrList = lib.types.either lib.types.str (lib.types.listOf lib.types.str);

  luaExpression = lib.types.submoduleOf {
    options = {
      __lua = lib.mkOption { type = lib.types.str; };
    };
  };

  boolOrLuaExpression = lib.types.oneOf [
    lib.types.bool
    luaExpression
  ];

  eventType = lib.types.oneOf [
    lib.types.str
    (lib.types.listOf lib.types.str)
    (lib.types.submodule {
      options = {
        event = lib.mkOption { type = strOrList; };
        pattern = lib.mkOption { type = strOrList; };
      };
    })
  ];

  mkLuaExpression = code: { __lua = code; };
  isLuaExpression = v: v ? __lua;

in
{
  options.programs.neovim.lzePlugins = lib.mkOption {
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
              default = config.plugin.name;
              description = ''
                Lua module used for require(). Defaults to the package name if unset.
              '';
            };

            # Options to use when automatically creating an after function to call setup
            options = lib.mkOption {
              type = lib.types.nullOr lib.types.attrs;
              default = null;
              description = ''
                Options passed to require('<module>').setup(...). Mutually exclusive with `after`.
              '';
            };

            beforeAll = lib.mkOption {
              type = lib.types.nullOr luaExpression;
              default = null;
              description = "Always executed upon calling require('lze').load(spec) before any plugin specs from that call are triggered to be loaded.";
            };

            before = lib.mkOption {
              type = lib.types.nullOr luaExpression;
              default = null;
              description = "Executed before the plugin is loaded.";
            };

            after = lib.mkOption {
              type = lib.types.nullOr luaExpression;
              default = null;
              description = "Executed after the plugin is loaded. Mutually exclusive with `options`.";
            };

            event = lib.mkOption {
              type = lib.types.nullOr eventType;
              default = null;
              description = "Lazy-load on event. Events can be specified as BufEnter or with a pattern like BufEnter *.lua.";
            };

            command = lib.mkOption {
              type = lib.types.nullOr strOrList;
              default = null;
              description = "Lazy-load on command.";
            };

            filetype = lib.mkOption {
              type = lib.types.nullOr strOrList;
              default = null;
              description = "Lazy-load on filetype.";
            };

            keys = lib.mkOption {
              type = lib.types.nullOr (lib.types.listOf lib.types.attrs);
              default = null;
              description = "Lazy-load on key mapping.";
            };

            colorscheme = lib.mkOption {
              type = lib.types.nullOr strOrList;
              default = null;
              description = "Lazy-load on colorscheme.";
            };

            dependencyOf = lib.mkOption {
              type = lib.types.nullOr strOrList;
              default = null;
              description = "Lazy-load before another plugin but after its before hook. Accepts a plugin name or a list of plugin names.";
            };

            onPlugin = lib.mkOption {
              type = lib.types.nullOr strOrList;
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
      This automatically injects plugins into the neovim configuration and sets up lazy loading in Lua.
      Keys are meaningless except to merge specs together.
    '';
  };

  config = {
    lib.mkLuaExpression = mkLuaExpression;
    lib.isLuaExpression = isLuaExpression;
  };
}
