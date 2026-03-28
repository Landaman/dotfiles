final: prev: {
  lmstudio =
    if final.stdenv.isDarwin then
      prev.lmstudio.overrideAttrs (oldAttrs: {
        meta.broken = false;

        nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ final.gnused ];

        postInstall = ''
          runHook postFixup
        ''
        + (oldAttrs.postInstall or "");

        postFixup = (oldAttrs.postFixup or "") + ''
          local indexJs="$out/Applications/LM Studio.app/Contents/Resources/app/.webpack/main/index.js"
          substituteInPlace "$indexJs" --replace-quiet "'/Applications'" "'/'"

          /usr/bin/codesign --force --deep --sign - "$out/Applications/LM Studio.app"
        '';
      })
    else
      prev.lmstudio;
}
