---
name: prm
description: Close out the current piece of work end to end — commit, push, open the pull request, merge it, then tell the user the conversation can be closed. Trigger whenever the user types "prm" on its own, or asks to "wrap up", "ship it" or "close this out".
---

# prm — ship it and close the conversation

`prm` means the work is done and the session is over. Run the four steps
below in order. Typing `prm` is the confirmation for all of them, the merge
included, so don't stop to ask between steps.

## 1. Commit

Commit everything still outstanding, including untracked files that belong to
the work. Use a conventional commit message, `@`-prefixed per the multi-commit
rule in `CLAUDE.md`.

If the working tree is already clean, skip to step 2 rather than making an
empty commit.

## 2. Push

Push to the branch this session was told to develop on, never another one:

```bash
git push -u origin <branch>
```

Retry up to four times on network failure, backing off 2s, 4s, 8s, 16s.

## 3. Open the pull request, then merge it

If the branch has no open pull request, create one. Look for a template
(`.github/pull_request_template.md`, `.github/PULL_REQUEST_TEMPLATE.md`, the
repository root, `docs/`) and fill its headings in if there is one; otherwise
write a body covering what changed and why.

Then merge it. Report the result plainly: if it is blocked by a failing
check, a conflict or a missing review, say exactly what is blocking and stop
there rather than forcing it through.

## 4. Say bye

Close with a short summary of what shipped and an explicit line saying the
conversation can be closed. Keep it to a few lines: the pull request is the
record, not the chat.
