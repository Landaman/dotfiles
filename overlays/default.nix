{ herdr, rex }:
[
  (import ./herdr.nix { inherit herdr; })
  (import ./rex.nix { inherit rex; })
  (import ./dotrush.nix)
  (import ./clrdbg.nix)
  (import ./herdr-app.nix)
  (import ./ghostty.nix)
  (import ./terraform.nix)
  (import ./corepack.nix)
  (import ./catppuccin-zsh-fsh.nix)
  (import ./zoxide-fzf-tmux-session.nix)
  (import ./chatgpt.nix)
  (import ./claude-code.nix)
  (import ./codex.nix)
  (import ./t3code.nix)
  (import ./pihole-ftl.nix)
]
