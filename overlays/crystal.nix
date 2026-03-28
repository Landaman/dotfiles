final: prev: {
  crystal = prev.crystal_1_18.overrideAttrs (_: {
    env.FLAGS = "--single-module";
  });
}
