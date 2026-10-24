final: prev:
let
  version = "0.164.0";
  # Keep the native V8 archive and generated bindings aligned with Cargo.lock
  v8Version = "152.2.0";
  v8Target = final.stdenv.hostPlatform.rust.rustcTarget;
  v8ArchiveHashes = {
    x86_64-linux = "sha256-tmg+mvy3f72MssOs9F001SApqyFrMyUiyVF5wS8P7Tw=";
    aarch64-linux = "sha256-xAGWu/GCUy5YP2W32vAZb9uzNU5vrFmzHQU5wg+THz0=";
    riscv64-linux = "sha256-h/uc4gRjDgiLpaQFlyIoggrFOoz0VfqUYnQM4GMPtxk=";
    aarch64-darwin = "sha256-pKVIREStS18Q3HvtFBI23Z2+q/IAbRRSDxm5NdTbQic=";
  };
  src = final.fetchFromGitHub {
    owner = "openai";
    repo = "codex";
    tag = "rust-v${version}";
    hash = "sha256-iib2+qQcGewC4Ga8cA80sInDJpzdSxDJP0y1DDOouI4=";
  };
in
{
  codex =
    (prev.codex.override {
      librusty_v8 = final.fetchurl {
        name = "librusty_v8-${v8Version}";
        url = "https://github.com/denoland/rusty_v8/releases/download/v${v8Version}/librusty_v8_release_${v8Target}.a.gz";
        hash = v8ArchiveHashes.${final.stdenv.hostPlatform.system};
      };
      librusty_v8_src_binding = final.fetchurl {
        name = "src_binding-${v8Version}";
        url = "https://github.com/denoland/rusty_v8/releases/download/v${v8Version}/src_binding_release_${v8Target}.rs";
        hash =
          if final.stdenv.hostPlatform.isDarwin then
            "sha256-udVlLrylFesr9MLuSmVRslZxF7Wqcg9DDSAyYW3X47U="
          else
            "sha256-Pk1f7Nvg+YpgF+adfKglGad/sDLF615M2+zdPi7FGdU=";
      };
    }).overrideAttrs
      (finalAttrs: {
        inherit version;
        inherit src;

        cargoDeps = final.rustPlatform.fetchCargoVendor {
          pname = "codex";
          inherit version src;
          sourceRoot = "${src.name}/codex-rs";
          hash = "sha256-0N2mEGqEl2ZjWqlbraVCWP0eoITgwmT9uO/1w/1eJno=";
        };
      });
}
