{ lib, ... }:
{
  options.agents.skills = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = { };
    description = "User-scoped agent skills. Keyed by skill name, with the full SKILL.md contents as values";
  };
}
