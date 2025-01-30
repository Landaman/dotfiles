{
  pkgs,
}:
with pkgs;
stdenvNoCC.mkDerivation {
  pname = "zoxide-fzf-tmux-session";
  version = "1";
  src = ./.;

  dontBuild = true;
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [
    tmux
    fzf
    zoxide
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp ./zoxide-fzf-tmux-session $out/bin/tmux-session
  '';
}
