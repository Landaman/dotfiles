final: prev:
let
  version = "0.1.3";
  appName = "T3 Code (Beta)";
  electron = final.electron_44;

  unwrapped = prev.t3code.unwrapped.overrideAttrs (
    finalAttrs: oldAttrs: {
      inherit version;

      src = final.fetchFromGitHub {
        owner = "pingdotgg";
        repo = "t3code";
        tag = "v${version}";
        hash = "sha256-xxmwaHPkXzR0CAtknCc6raAzcnPtmw8wxF3YO3WcbE4=";
      };

      pnpmDeps = final.fetchPnpmDeps {
        inherit (finalAttrs)
          pname
          version
          src
          pnpmWorkspaces
          ;
        pnpm = final.pnpm_11;
        fetcherVersion = 4;
        hash = "sha256-t7DWJow4pdsqbFnMA+p3TDjYkr1asdFStnvnDxuxnFw=";
      };

      postInstall =
        oldAttrs.postInstall
        + final.lib.optionalString final.stdenv.hostPlatform.isDarwin ''
          # Packaged mode resolves both the desktop and backend from this root
          mkdir -p stage/apps/{desktop,server}
          cp -R "$out/libexec/t3code/apps/desktop/"{dist-electron,prod-resources} stage/apps/desktop/
          cp -R "$out/libexec/t3code/apps/server/dist" stage/apps/server/
          cat > stage/package.json <<'EOF'
          ${builtins.toJSON {
            name = "t3code";
            inherit version;
            description = "Control surface for coding agents";
            license = "MIT";
            author = "T3 Tools";
            main = "apps/desktop/dist-electron/boot.cjs";
          }}
          EOF
          cat > electron-builder.json <<'EOF'
          ${builtins.toJSON {
            appId = "com.t3tools.t3code";
            productName = appName;
            electronVersion = electron.version;
            directories.output = "bundle";
            asar = false;
            npmRebuild = false;
            publish = null;
            files = [
              "**/*"
              "!**/*.map"
            ];
            mac = {
              identity = null;
              category = "public.app-category.developer-tools";
              icon = "icon.icns";
            };
          }}
          EOF
          cp "$out/Applications/T3 Code (Alpha).app/Contents/Resources/t3code.icns" stage/icon.icns
          cp -R ${electron.dist} electron-dist
          chmod -R u+w electron-dist
          export CSC_IDENTITY_AUTO_DISCOVERY=false
          node "$out/libexec/t3code/apps/desktop/node_modules/electron-builder/cli.js" \
            --projectDir stage --config "$PWD/electron-builder.json" \
            -c.electronDist="$PWD/electron-dist" --dir --mac --${final.stdenv.hostPlatform.node.arch}

          rm -r "$out/Applications"
          mkdir -p "$out/Applications"
          mv stage/bundle/mac*/'${appName}.app' "$out/Applications/"
          app="$out/Applications/${appName}.app/Contents/Resources/app"
          # Keep pnpm's native modules and executable helpers outside an archive
          ln -s "$out/libexec/t3code/node_modules" "$app/node_modules"
          for component in desktop server; do
            ln -s "$out/libexec/t3code/apps/$component/node_modules" "$app/apps/$component/node_modules"
          done
          rm "$out/bin/t3code-desktop"
          makeWrapper "$out/Applications/${appName}.app/Contents/MacOS/${appName}" \
            "$out/bin/t3code-desktop" --set T3CODE_DISABLE_AUTO_UPDATE true
        '';
    }
  );

  resourceMonitor = prev.t3code.resourceMonitor.override {
    t3code-unwrapped = unwrapped;
  };
in
{
  t3code = prev.t3code.override (
    {
      t3code-unwrapped = unwrapped;
      t3code-resource-monitor = resourceMonitor;
    }
    // final.lib.optionalAttrs final.stdenv.hostPlatform.isDarwin {
      # Apply upstream's optional provider environment to Finder launches too
      symlinkJoin =
        args:
        final.symlinkJoin (
          args
          // {
            postBuild = args.postBuild + ''
              rm -r "$out/Applications/${appName}.app"
              cp -R '${unwrapped}/Applications/${appName}.app' "$out/Applications/"
              chmod -R u+w "$out/Applications/${appName}.app"
              app="$out/Applications/${appName}.app/Contents/Resources/app"

              # Capture only upstream's optional runtime environment, without the build PATH
              env -u PATH -u T3CODE_RESOURCE_MONITOR_PATH ELECTRON_RUN_AS_NODE=1 \
                "$out/bin/t3code-desktop" -e '
                  const fs = require("node:fs");
                  const path = require("node:path");
                  const app = process.argv[1];
                  fs.writeFileSync(path.join(app, "nix-environment.json"), JSON.stringify({
                    providerPath: process.env.PATH,
                    resourceMonitorPath: process.env.T3CODE_RESOURCE_MONITOR_PATH,
                  }));
                  const manifestPath = path.join(app, "package.json");
                  const manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));
                  manifest.main = "nix-entry.cjs";
                  fs.writeFileSync(manifestPath, JSON.stringify(manifest));
                ' "$app"

              # Keep Electron as CFBundleExecutable so LaunchServices retains its real PID
              cat > "$app/nix-entry.cjs" <<'EOF'
              const { providerPath, resourceMonitorPath } = require("./nix-environment.json");
              if (providerPath) {
                process.env.PATH = [providerPath, process.env.PATH].filter(Boolean).join(require("node:path").delimiter);
              }
              if (resourceMonitorPath && process.env.T3CODE_RESOURCE_MONITOR_PATH === undefined) {
                process.env.T3CODE_RESOURCE_MONITOR_PATH = resourceMonitorPath;
              }
              process.env.T3CODE_DISABLE_AUTO_UPDATE = "true";
              require("./apps/desktop/dist-electron/boot.cjs");
              EOF
              rm "$out/bin/t3code-desktop"
              # Electron needs the bundle executable's argv[0] to locate its helpers
              makeWrapper "$out/Applications/${appName}.app/Contents/MacOS/${appName}" "$out/bin/t3code-desktop"
            '';
          }
        );
    }
  );
}
