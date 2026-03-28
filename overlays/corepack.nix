final: prev: {
  corepack_22 = prev.corepack_22.overrideAttrs (oldAttrs: {
    nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [
      final.installShellFiles
      final.cacert
    ];

    installPhase = ''
      runHook preInstall
    ''
    + oldAttrs.installPhase
    + ''
      runHook postInstall
    '';

    postInstall = (oldAttrs.postInstall or "") + ''
      export COREPACK_HOME=$out/tmp && installShellCompletion --cmd pnpm --zsh <($out/bin/pnpm completion zsh) --bash <($out/bin/pnpm completion bash);
    '';
  });
}
