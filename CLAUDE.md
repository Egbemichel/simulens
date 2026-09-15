# SimuLens — Git & GitHub Workflow Rules

These rules are **non-negotiable** and apply to every session working in
this repository, not just this one. They were established explicitly by
the repository owner (Egbemichel) after a git-history cleanup and must be
followed without being re-asked.

## 1. Authorship

- The repository owner is the **sole author** of all commits.
- **Never** add any AI attribution to a commit, trailer, PR description, or
  repository file: no `Co-authored-by: Claude`, no `Co-authored-by:
  Anthropic`, no Claude/Anthropic listed as author, no session links, no
  similar trailer — unless the owner explicitly asks for one in that
  specific instance.
- Git identity for this repo (already set locally, do not change without
  being asked):
  ```
  user.name  = Egbemichel
  user.email = egbemichel39@gmail.com
  ```
- **Before every commit**, verify identity:
  ```
  git config user.name
  git config user.email
  ```
  If either is missing or wrong, **STOP and report it** — do not guess or
  substitute a default.

## 2. `main` is canonical

- `main` is the protected, production/stable branch and is to be treated as
  this repository's default branch **in all Claude behavior**, regardless
  of what GitHub's own "default branch" UI setting currently shows.
- **Known outstanding item**: GitHub's repository setting still lists the
  old `claude/simulens-repo-init-mipp3k` branch as the default branch,
  because changing that setting requires the GitHub web UI (Settings →
  Branches), which the owner could not reach from mobile. That branch is to
  be treated as **not existing** — never branch from it, never merge it,
  never reference it as current. Once the owner confirms they've changed
  the GitHub default branch to `main`, delete
  `claude/simulens-repo-init-mipp3k` from GitHub (`git push origin --delete
  claude/simulens-repo-init-mipp3k`) and remove this paragraph.
- **Never** commit directly to `main`. **Never** push unfinished or
  in-progress work to `main`.
- All changes reach `main` only by merging a pull request (see §5).

## 3. Branch naming

Use conventional category prefixes, lowercase kebab-case:

```
feature/<short-description>
fix/<short-description>
hotfix/<short-description>
refactor/<short-description>
docs/<short-description>
test/<short-description>
chore/<short-description>
```

Examples: `feature/baseline-simulation`, `feature/traffic-demand`,
`fix/sumo-network`, `docs/methodology`, `chore/ci-setup`.

Do **not** create generic branches such as `claude/*`, `work`, `temp`,
`test`, `dev` unless explicitly asked to.

## 4. Commit messages

Use Conventional Commits style:

```
feat: add baseline traffic simulation
fix: correct SUMO network conversion
docs: document OSM extraction methodology
chore: configure simulation environment
test: validate baseline simulation
```

No AI attribution trailers (see §1).

## 5. Feature workflow — always use PRs

For every task, in this exact order:

1. Start from the latest `main` (`git checkout main && git pull origin
   main`).
2. Create an appropriately named task branch (§3).
3. Make the changes there.
4. Review the changes (`git status` / `git diff`) before staging.
5. Commit with a clean Conventional Commit message, no AI trailers, correct
   identity (§1, §4).
6. Push the task branch to origin.
7. **Open a pull request into `main`.** Direct pushes to `main` are never
   used — every change lands via a PR, even for solo/self-reviewed work.
8. Merge the PR into `main` once the task is complete.
9. Delete the task branch locally.
10. Delete the task branch on GitHub.
11. Return to `main` locally.
12. Pull/update `main`.

```
main
  ↓
feature/baseline-simulation
  ↓ commit → push → PR → merge → main
  ↓
delete feature/baseline-simulation (local + remote)
  ↓
back to main, pulled up to date
```

## 6. Pre-commit checklist

Before every commit:

1. Confirm the current branch is **not** `main`.
2. Confirm git author identity (§1).
3. Review staged files (`git status`, `git diff --staged`).
4. Review the commit message.
5. Confirm no AI attribution/trailers are present.
6. Commit.
7. Push only the task branch (never `main` directly).

## 7. CI/CD

Keep it minimal for now — no complex CI. The branch/PR workflow above is
the priority; CI can be introduced later to run on pull requests targeting
`main`.

## 8. History

`main`'s current history was rewritten once (git filter-branch) to correct
authorship and strip AI attribution trailers from the repository's first
three commits, with the owner's explicit authorization. That is a one-time
cleanup, not a standing practice — do not rewrite history again without
being explicitly asked.
