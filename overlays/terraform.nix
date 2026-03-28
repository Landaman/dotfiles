final: prev: {
  terraform = prev.terraform.overrideAttrs (oldAttrs: {
    nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ final.installShellFiles ];
    postInstall = oldAttrs.postInstall + ''
      installShellCompletion --name _terraform --zsh <(cat <<EOF
        #compdef terraform

        autoload -U +X bashcompinit && bashcompinit
        complete -C $out/bin/terraform terraform
      EOF)
    '';
  });
}
