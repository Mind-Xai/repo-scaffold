Write-Output "Running local checks..."

if (Test-Path package.json) {
  Write-Output "Installing Node dependencies (npm ci)..."
  npm ci
  $npmExit = $LASTEXITCODE
  if ($npmExit -ne 0) { Write-Error "npm ci failed with exit code $npmExit"; exit $npmExit }

  if (Test-Path test\test.js) {
    Write-Output "Running npm test..."
    npm test
    $testExit = $LASTEXITCODE
    if ($testExit -ne 0) { Write-Error "Tests failed with exit code $testExit"; exit $testExit }
  } else {
    Write-Output "No tests found at test\test.js; skipping tests."
  }
} else {
  Write-Output "No package.json found; skipping npm steps."
}

Write-Output "Running gatherer to refresh repo_facts.txt..."
if (Test-Path .\tools\gather_repo_facts_fixed.ps1) {
  powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\gather_repo_facts_fixed.ps1
} else {
  Write-Output "gather_repo_facts_fixed.ps1 not found in tools/; aborting gather step."
}

Write-Output "Local checks completed. Review output for errors."
