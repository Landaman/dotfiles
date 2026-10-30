final: prev: {
  corepack_22 = prev.corepack_22.overrideAttrs (oldAttrs: {
    nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [
      final.installShellFiles
    ];

    installPhase = ''
      runHook preInstall
    ''
    + oldAttrs.installPhase
    + ''
      runHook postInstall
    '';

    postInstall = (oldAttrs.postInstall or "") + ''
      export HOME=$TMPDIR && installShellCompletion --cmd pnpm \
        --zsh <(${final.pnpm}/bin/pnpm completion zsh) \
        --bash <(${final.pnpm}/bin/pnpm completion bash) \
        --fish <(${final.pnpm}/bin/pnpm completion fish);
    '';
  });
}
