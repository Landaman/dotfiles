{
  config,
  lib,
  pkgs,
  ...
}:

let
  username = config.user.username;

  lzeGenerate = import ./lze-generate.nix { inherit lib pkgs; };

  processedPluginSpecs = (
    lib.mapAttrsToList (_: spec: lzeGenerate spec) (config.programs.lzePlugins or { })
  );

  lzePlugins = lib.filter (package: package != null) (
    lib.map (spec: spec.package) processedPluginSpecs
  );
  allPlugins = [
    # Load lze on startup to let it load everything else
    {
      plugin = pkgs.vimPlugins.lze;
      optional = false;
    }
  ]
  ++ lzePlugins;

  luaSpecStrings = lib.concatStringsSep "," (
    lib.filter (s: s != null) (lib.map (spec: spec.luaSpec) processedPluginSpecs)
  );
  setupLzeLuaExpression =
    if luaSpecStrings == "" then "" else "require(\"lze\").load({${luaSpecStrings}})";
in
{
  home-manager.users.${username}.programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraPackages = with pkgs; [
      tree-sitter
    ];
    plugins = allPlugins;
    initLua = setupLzeLuaExpression;
  };
}
