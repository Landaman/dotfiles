{
  pkgs,
  neverIgnore,
  ignore,
  alwaysIgnore,
}:
with pkgs;
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


    no_ignore_regex='\B(?:--no-ignore|-u+|--unrestricted)\b'

    if [[ $* =~ $no_ignore_regex ]]; then
      fd "$@" --ignore-file=${alwaysIgnore}
    else
      fd "$@" --ignore-file=${ignore} --ignore-file=${alwaysIgnore}
    fi
  '';
}
