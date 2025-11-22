$outFile = Join-Path (Get-Location) 'repo_facts.txt'
Try { Remove-Item $outFile -ErrorAction SilentlyContinue } Catch {}
Function W { param($s) Add-Content -Path $outFile -Value $s -Encoding utf8 }
W ("Repository facts generated: {0}" -f (Get-Date -Format o))
W ("WorkingDir: {0}" -f (Get-Location).Path)
W "---- TOP-LEVEL FILES ----"
Get-ChildItem -Path . -Force -File | Sort-Object Name | ForEach-Object { W ("- {0}" -f $_.Name) }

W "---- DETECTED MANIFESTS ----"
$manifests = @('README.md','package.json','pyproject.toml','go.mod','pom.xml','Cargo.toml','Dockerfile','.env.example','requirements.txt','Pipfile','composer.json')
foreach ($m in $manifests) {
  if (Test-Path $m) {
    W ("Found: {0}" -f $m)
    W ("----- START {0} -----" -f $m)
    try { Get-Content $m -ErrorAction Stop | Select-Object -First 200 | ForEach-Object { W $_ } } catch { W ("Error reading {0}: {1}" -f $m, $_.Exception.Message) }
    W ("----- END {0} -----" -f $m)
  }
}

if (Test-Path .github\workflows) {
  W "---- GITHUB WORKFLOWS ----"
  Get-ChildItem .github\workflows -File -Recurse | ForEach-Object {
    W ("Workflow: {0}" -f $_.FullName)
    W ("----- START WORKFLOW -----")
    Get-Content $_ -ErrorAction SilentlyContinue | Select-Object -First 200 | ForEach-Object { W $_ }
    W ("----- END WORKFLOW -----")
  }
}

W "---- API CONTRACT FILES (proto/openapi) ----"
$apiFiles = Get-ChildItem -Path . -Include *.proto,'openapi*.yaml','openapi*.yml','openapi*.json' -File -Recurse -ErrorAction SilentlyContinue
foreach ($f in $apiFiles) {
  W ("File: {0}" -f $f.FullName)
  W ("----- START FILE -----")
  Get-Content $f -ErrorAction SilentlyContinue | Select-Object -First 200 | ForEach-Object { W $_ }
  W ("----- END FILE -----")
}

W "---- TOP 100 FILES (by name) ----"
Get-ChildItem -Path . -Recurse -File -ErrorAction SilentlyContinue | Sort-Object FullName | Select-Object -First 100 | ForEach-Object { W ("- {0}" -f $_.FullName) }

if (Test-Path .git) {
  W "---- GIT INFO ----"
  try {
    $branch = (git rev-parse --abbrev-ref HEAD 2>$null).Trim()
    if ($branch) { W ("Branch: {0}" -f $branch) }
  } catch { W "git not available or failed to run." }
}

W "---- DONE ----"
