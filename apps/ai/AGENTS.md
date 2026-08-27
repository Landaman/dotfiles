# AI Coding Assistant

Hi, I'm Ian, we're going to be working together. I thought I'd explain
a little bit about what good work looks like to me so we can
collaborate easier

## Git

### Commit Messages

For Git commits, I like to use the "imperative" style with the Linux-style line
lengths (50 for the summary, 72 for the body). I also like linking issue #s
in the trailer if they exist

Good example:

```git
Safely skip users with no auth token in sync job

Previously, if any user had a missing token the entire background job would fail.
We tried to use the refresh token in a URL, which caused a null exception.

Issue: #12
```

Bad example:

```git
fix: #12 crash in the background sync job
```

### Commits

I prefer to break up commits per issue. They should each be functional,
digestible units to review. It's okay if they build on each other.

### Branch Names

Each branch should be named based on the function, i.e., `fix-no-auth-token`.
There is no need to prefix the branch name with `codex/`. The only reason
to prefix a branch name is if we're doing a bunch of stacked PRs building
on each other for a feature
