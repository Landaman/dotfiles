final: prev: {
  ghostty =
    if prev.stdenv.isDarwin then
      prev.stdenvNoCC.mkDerivation rec {
        inherit (prev.ghostty)
          pname
          version
          ;

        meta = prev.ghostty.meta // {
          platforms = prev.ghostty.meta.platforms ++ [ "aarch64-darwin" ];
          outputsToInstall = outputs;
        };

        src = prev.fetchurl {
          url = "https://release.files.ghostty.org/${version}/Ghostty.dmg";
          name = "Ghostty.dmg";
          hash = "sha256-817pHxFuKAJ6ufje9FCYx1dbRLQH/4g6Lc0phcSDIGs=";
        };

        nativeBuildInputs = [
          final._7zz
          final.makeBinaryWrapper
        ];

        unpackPhase = ''
          7zz x -snld $src
        '';

        sourceRoot = ".";
        installPhase = ''
          runHook preInstall

          mkdir -p $out/Applications
          mv Ghostty.app $out/Applications/
          makeWrapper $out/Applications/Ghostty.app/Contents/MacOS/ghostty $out/bin/ghostty

          runHook postInstall
        '';

        outputs = [
          "out"
          "man"
          "shell_integration"
          "terminfo"
          "vim"
        ];

        postFixup =
          let
            resources = "$out/Applications/Ghostty.app/Contents/Resources";
          in
          ''
            mkdir -p $man/share
            ln -s ${resources}/man $man/share/man

            mkdir -p $terminfo/share
            ln -s ${resources}/terminfo $terminfo/share/terminfo

            mkdir -p $shell_integration
            for folder in "${resources}/ghostty/shell-integration"/*; do
                    ln -s $folder $shell_integration/$(basename "$folder")
            done

            mkdir -p $vim
            for folder in "${resources}/vim/vimfiles"/*; do
                    ln -s $folder $vim/$(basename "$folder")
            done

            mkdir -p $out/share/bash-completion
            cp -R ${resources}/bash-completion/* $out/share/bash-completion

            mkdir -p $out/share/zsh
            cp -R ${resources}/zsh/* $out/share/zsh

            mkdir -p $out/share/fish
            cp -R ${resources}/fish/* $out/share/fish

            mkdir -p $out/share/bat
            cp -R ${resources}/bat/* $out/share/bat
          '';
      }
    else
      prev.ghostty;
}
