{ herdr }:
final: _prev: {
  herdr = herdr.packages.${final.stdenv.hostPlatform.system}.default;
}
