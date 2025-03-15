{
  pkgs,
}:
with pkgs;
let
  neverIgnore = pkgs.writeText ".fzfnoignore" ''
    **/*
    !.env*
    !.vscode/
    !.vscode/**/*
  '';

  ignore = pkgs.writeText ".fzfignore" ''
    .DS_Store
    metals.sbt
    node_modules/
    .git/
    .venv/
    __pycache__/
    .metals/
    .bloop/
    .ammonite/
    .turbo/
    .firebase/
    .next/
    .svelte-kit/
    .husky/_
  '';

in
writeShellApplication {
  name = "fdi";

  runtimeInputs = [
    fd
  ];

  text = ''
    #!/usr/bin/env bash

    filtered_args=()

    for arg in "$@"; do
        if [[ "$arg" == "--ignore" ]]; then
            continue
        fi
        
        if [[ "$arg" == --ignore-file=* ]]; then
            continue
        fi
        
        filtered_args+=("$arg")
    done

    fd "''${filtered_args[@]}" -u --ignore-file=${neverIgnore}


    no_ignore_regex='\B(?:--no-ignore|-u|--unrestricted)\b'

    if [[ $* =~ $no_ignore_regex ]]; then
      fd "$@"
    else
      fd "$@" --ignore-file=${ignore}
    fi
  '';
}
