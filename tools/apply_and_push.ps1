Write-Output "Preparing to commit and push changes..."

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Write-Error "git is not available in PATH. Install/configure git and run this script again."
  exit 1
}

$status = git status --porcelain
Write-Output "Current git status (porcelain):"
Write-Output $status

Write-Output "Files to add:"
@(
  ".github/copilot-instructions.md",
  "README.md",
  ".github/workflows/gather.yml",
  "package.json",
  "src/index.js",
  "test/test.js",
  ".gitignore",
  "tools/gather_repo_facts_fixed.ps1",
  "tools/run_local_checks.ps1",
  "tools/apply_and_push.ps1"
) | ForEach-Object { Write-Output " - $_" }

$confirm = Read-Host "Stage these files and commit with message 'chore: scaffold Node.js, add copilot instructions and CI'? (y/N)"
if ($confirm -ne 'y' -and $confirm -ne 'Y') {
  Write-Output "Aborting commit as requested."
  exit 0
}

git add .github/copilot-instructions.md README.md .github/workflows/gather.yml package.json src/index.js test/test.js .gitignore tools/gather_repo_facts_fixed.ps1 tools/run_local_checks.ps1 tools/apply_and_push.ps1

try {
  git commit -m "chore: scaffold Node.js, add copilot instructions and CI"
} catch {
  Write-Error "git commit failed. Output: $_"
  exit 1
}

$pushConfirm = Read-Host "Push commit to remote 'origin'? (y/N)"
if ($pushConfirm -eq 'y' -or $pushConfirm -eq 'Y') {
  try {
    git push origin HEAD
    Write-Output "Push completed (check git output above)."
  } catch {
    Write-Error "git push failed. Output: $_"
    exit 1
  }
} else {
  Write-Output "Skipping push. You can push manually with: git push origin HEAD"
}
