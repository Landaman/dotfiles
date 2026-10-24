# configuration: Evaluated system configuration containing the Neovim settings
{ configuration }:

let
  inherit (configuration) pkgs;
  inherit (pkgs) lib;
  username = configuration.config.user.username;
  neovim = configuration.config.home-manager.users.${username}.programs.neovim;
  generated = import ./generate-config.nix { inherit lib pkgs neovim; };
  nixToLua = import ./nix-to-lua.nix { inherit lib; };

  # Helper to normalize plugin config to only what we really need
  normalizePlugin =
    pluginConfig:
    let
      plugin = pluginConfig.plugin or pluginConfig;
    in
    {
      key = plugin.pname;
      inherit plugin;
      # For plugins we have config for, let lze do it. Otherwise, we need to assume they need to be loaded on startup
      optional = pluginConfig.optional or false;
    };

  # Flat map to all plugins and whether they need to be imported on startup
  pluginsWithDependencies = builtins.genericClosure {
    startSet = map normalizePlugin neovim.plugins;
    operator = pluginConfig: map normalizePlugin (pluginConfig.plugin.dependencies or [ ]);
  };

  # Helper to convert each plugin to something that nvim packadd can load
  pluginSpec =
    { plugin, ... }:
    let
      archiveUrl = plugin.src.url or (builtins.head plugin.src.urls);
      # Annoyingly, some plugins use an archive and aren't smart about fetching, so we need to tear those apart
      archiveParts = builtins.match "(https://github.com/[^/]+/[^/]+)/archive/(.+)\\.(tar\\.gz|zip)" archiveUrl;
      archiveSpec =
        if archiveParts == null then
          throw "neovim-export: cannot determine the repository and revision for ${plugin.pname}"
        else
          {
            src = builtins.elemAt archiveParts 0;
            version = builtins.elemAt archiveParts 1;
          };
    in
    {
      src = plugin.src.gitRepoUrl or archiveSpec.src;
      name = plugin.pname;
      version = plugin.src.rev or archiveSpec.version;
    };

  startupPlugins = map pluginSpec (
    lib.filter (pluginConfig: !pluginConfig.optional) pluginsWithDependencies
  );
  optionalPlugins = map pluginSpec (
    lib.filter (pluginConfig: pluginConfig.optional) pluginsWithDependencies
  );

  # Load required plugins right awawy, let optional plugins be loaded by lze
  # false means do :packadd!, so we need to manually skip the optional ones
  installLua = ''
    if vim.fn.has('nvim-0.12') == 0 then
      error('This configuration requires Neovim 0.12 or newer')
    end

    -- Load required plugins right away with packadd
    vim.pack.add(${nixToLua.toLuaValue startupPlugins}, { load = false, confirm = false })
    -- Leave optional plugins off runtimepath until lze loads them
    vim.pack.add(${nixToLua.toLuaValue optionalPlugins}, { load = function() end, confirm = false })
  '';

  # The output will need to actually be edited by hand to remove
  # the nix dependencies. This essentially means "create a new package that drops those"
  initLua = pkgs.writeText "nvim-export-init.lua" (
    builtins.unsafeDiscardStringContext (installLua + "\n" + generated.initLua)
  );
in
pkgs.runCommand "neovim-export" { } ''
  mkdir -p "$out/nvim"
  cp ${initLua} "$out/nvim/init.lua"
  ${lib.concatStringsSep "\n" (
    lib.mapAttrsToList (configPath: configFile: ''
      mkdir -p "$out"/${lib.escapeShellArg (dirOf configPath)}
      cp -L ${lib.escapeShellArg (toString configFile.source)} "$out"/${lib.escapeShellArg configPath}
    '') generated.extraConfigXdgFiles
  )}
''
