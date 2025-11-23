# Copilot / AI Agent Instructions

This repository contains helper scripts and a small Node.js scaffold to enable automated discovery of repository facts and a minimal CI smoke test.

Quick actions (repo-specific)

- Run the gatherer locally (from repository root):

  powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\gather_repo_facts_fixed.ps1

- Run the project's tests locally:

  npm test

- Download the `repo_facts` artifact produced by CI (requires `gh` CLI):

  gh run download --repo Mind-Xai/repo-scaffold --name repo_facts --dir ./artifacts

  After running, inspect: `./artifacts/repo_facts/repo_facts.txt`.

What the gatherer produces (summary for agents)

- `repo_facts.txt` — a short inventory that lists top-level files, detected manifests (e.g. `package.json`, `README.md`), workflow contents, and a short file sample. It is created in the repository root by the gather script.

- In this repository the gatherer detected `package.json` and `README.md`. `package.json` contains a `test` script that runs `node ./test/test.js`.

CI notes

- Workflow: `.github/workflows/gather.yml` — runs the gatherer, installs Node.js, runs `npm test`, and uploads `repo_facts` as an action artifact. The upload step uses `actions/upload-artifact@v4` and is configured to run even if earlier steps fail, so `repo_facts` should be available for inspection.

Recommended agent workflow

1. Run the gatherer locally and attach `repo_facts.txt` when asking for code changes.
2. If you need CI output, download the `repo_facts` artifact from the latest run using `gh run download` and inspect `repo_facts.txt`.
3. Use `npm test` to reproduce the CI smoke test locally.

If you want, I can (A) add a workflow badge to `README.md`, (B) tighten the `copilot-instructions.md` further, or (C) expand the gatherer to extract license and language stats — tell me which and I'll prepare a patch.
