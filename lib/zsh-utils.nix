{ pkgs }:
rec {
  # Function that returns a version of the provided function that is precompiled using zcompile
  packageWithZCompile =
    {
      package,
      path,
      file,
      name ? package.pname,
    }:
    {
      inherit name;
      file = file;

      src = "${
        (package.overrideAttrs (oldAttrs: {
          nativeBuildInputs = oldAttrs.nativeBuildInputs or [ ] ++ [ pkgs.zsh ]; # Ensure Zsh is available

          installPhase =
            oldAttrs.installPhase or ""
            + ''
              mkdir -p $out/share/${path}
              ${pkgs.zsh}/bin/zsh -c "zcompile -R -- $out/share/${path}/${file}.zwc $out/share/${path}/${file}"
            '';
        }))
      }/share/${path}";
    };

  # Function that makes a new zsh file that sources everything in the path, and then zcompiles that
  packageWithZCompileAll =
    {
      package,
      path,
      name ? package.pname,
    }@inputs:
    (packageWithZCompile rec {
      inherit name path;
      file = "nix_internal_all.zsh";
      package = inputs.package.overrideAttrs (oldAttrs: {
        installPhase =
          oldAttrs.installPhase or ""
          + ''
            mkdir -p $out/share/${path}
            for file in $out/share/${path}/*.zsh; do
              echo "source $(basename $file)" >> $out/share/${path}/${file}
            done
          '';
      });
    });
}
