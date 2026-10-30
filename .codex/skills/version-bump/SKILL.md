---
name: version-bump
description: Use when the user asks you to update the Nix version of one or more Nix packages or the system flake nixpkgs
---

# Nix Version Bump

This workflow is meant to aid you in understanding the users expectations when
they ask you to bump versions of one or more Nix packages.

Many packages in this repository are versioned using overlays, so they can
be updated more quickly than their `nixpkgs` equivalent.

All overlays in this repository are in the `overlays/` directly. This flake
is intended for use both on macOS (Darwin) and on Linux.

## Pre-Update

Before any update, you should make sure you have a clear understanding of what
the user is expecting you to update. "everything" or "all" are acceptable answers.
You should not update anything outside of what the user asks
If there is any ambiguity in the users request, you should stop and tell them.

### Nixpkgs

If the user asks you to update nixpkgs, you can assume they want everything updated.
Outside of a request to update nixpkgs, you should not do anything that would change
the pinned nixpkgs version. If the user requests you update a package that
requires this, you should stop and tell them that.

### Other Items in flake.lock

Anything else in flake.lock should follow the rule of being updated as the user
requests it

## During Update

### Pre-Update Overlays

Overlays in this repository are broken up into two categories.

In either case, you **MUST** change all hashes and checksums for packages you
are updating (directly or indirectly). You do not need to know the correct
version in advance of doing this. You just need to change it in order to break
the Nix cache. In the post-update step, we will correct them.

#### Permanent

These are intended to keep the version of the package used in
this repository ahead of the nixpkgs equivalent. These will
typically have a `version` field.

When updating these types of packages, you should find the latest version.
This will typically involve going to the web and finding the source. This
may be a GitHub repository with releases, or may be a private binary archive.

In any case, you should be sure to use the web to find the latest version.
For packages that have separate binary archives for different platforms, if you
can only find the latest binary for your platform, try the link to the other
platforms with the version you found filled in.

If you are at all uncertain in what the latest version is, you should abandon
changing that package (you can leave one platform unchanged if you figured
out the package but not on one platform). You may continue with any approved work
anyway, but tell the user.

#### Temporary

These are meant to fix issues with the upstream content, for one reason
or another. These typically do not include a `version` field.

If updating the source of the overlay, you should check if upstream changes
have made the overlay redundant (i.e., upstream issue fixed). If so,
you should delete the overlay and explain this to the user.

## Post-Update

After any change, you should build but not activate the system flake.

If you run into any errors, follow the guidance below. Unless the guidance
below indicates you should stop, you should make the changes necessary
and continue rebuilding until the build either succeeds or you run into
a stop condition.

### Upstream Changes

If something in an upstream dependency changes such that some configuration or
overlay in the repo needs to change, you should make the change and report what
happened to the user.

#### Upstream Bugs

If there is a bug in the upstream source of a package, you should attempt to patch
it with an overlay. There may be useful guidance in the nixpkgs issues on GitHub.
If you cannot patch the bug, stop and tell the user. If you were able to patch
the bug, just report it to the user at the end with any context on the fix.

### Post-Update Overlays

Nix will give you the correct version of each hash/checksum you changed. Use those
values from Nix in the overlay to continue your work.

If a hash/checksum you did not change is reported as invalid, stop and tell the
user.

#### Other Platforms

You should try to update the hashes/checksums for other platforms.
A Linux builder is available for your use on this system.

## Result

Create a table showing the user each package that was changed, the old version,
and the new version. `nixpkgs` itself counts as one package for this purpose.

You should also include any caveats indicated above as necessary.
