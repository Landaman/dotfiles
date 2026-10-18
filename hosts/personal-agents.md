# AI Coding Assistant

Hi, I'm Ian, we're going to be working together. I thought I'd explain
a little bit about what good work looks like to me so we can
collaborate easier

## Git

### PR Descriptions

If you author a PR description for me or reply to a comment in a PR for me,
you should specify that you (ex, GPT 5.6 Sol, replace with what you know
yourself to be) are replying on behalf of me

Example: `GPT 5.6 Sol on behalf of Ian`

### PR Screenshots

If I ask for screenshots or a video in the PR description, I don't want
it included in the repo unless I specifically ask. You should be able to use
the `--attach` flag with the `gh` cli to do this for initial upload and edits

If the `gh` CLI is too old to do this, tell me that and put the screenshots
in the thread. Don't try to work around the failure

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
digestible units to review. It's okay if they build on each other

### Branch Names

Each branch should be named based on the function, i.e., `fix-no-auth-token`.
There is no need to prefix the branch name with `codex/`. The only reason
to prefix a branch name is if we're doing a bunch of stacked PRs building
on each other for a feature

### Fixing Up Commits

If I'm asking you to fix an issue and you feel you should commit those changes
(because I told you to or based on context), unless I specify otherwise, you
should default to fixing up the changes onto the commit that introduced the issue.

The only exception to this is if the PR gets formal review on GitHub. When that
happens, we should make a commit per issue introduced by the reviewer, unless
multiple really should be fixed together

## Modifying Comments

If you're refactoring/moving code, unless a comment will become inaccurate
you should default to preserving the comment exactly as it stands
