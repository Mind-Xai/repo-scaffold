# Tries candidate repo paths, ensures gather script exists, runs it, and reports the result.
Set-StrictMode -Off
$ErrorActionPreference = 'Continue'

$candidates = @(
    "$env:USERPROFILE\Documents\Mind-Xai-HQ",
    "$env:USERPROFILE\Documents\mindx-ai",
    "$env:USERPROFILE\Projects",
    "$env:USERPROFILE\source",
    (Get-Location).Path
)

function Ensure-GatherScript {
    param([string]$repoRoot)
    $scriptPath = Join-Path $repoRoot 'tools\gather_repo_facts.ps1'
    if (-not (Test-Path $scriptPath)) {
        Write-Output "Creating gather script at: $scriptPath"
        $dir = Join-Path $repoRoot 'tools'
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        # Copy from same folder: create the script file from this helper's content (assumes caller created gather script already).
        # For simplicity, create a minimal wrapper that calls gather_repo_facts.ps1 if missing.
        $template = Get-Content -Path (Join-Path $PSScriptRoot 'gather_repo_facts.ps1') -Raw -ErrorAction SilentlyContinue
        if ($template) {
            $template | Out-File -FilePath $scriptPath -Encoding utf8 -Force
        } else {
            # Fallback: create a small script that signals missing full script
            "Write-Output 'gather_repo_facts.ps1 missing in tools. Please create it and rerun.'" | Out-File -FilePath $scriptPath -Encoding utf8 -Force
        }
    }
    return $scriptPath
}

foreach ($c in $candidates) {
    if (-not (Test-Path $c)) { continue }
    Write-Output "`nTrying candidate: $c"
    try { Set-Location -Path $c } catch { Write-Warning "Cannot Set-Location: $($_.Exception.Message)"; continue }
    Write-Output "Location: $(Get-Location)"
    $scriptPath = Ensure-GatherScript -repoRoot (Get-Location).Path
    Write-Output "Using gather script: $scriptPath"
    Write-Output "Running gather script..."
    try {
        powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath 2>&1 | ForEach-Object { Write-Output $_ }
        if (Test-Path .\repo_facts.txt) {
            Write-Output "SUCCESS: repo_facts.txt created at: $(Resolve-Path .\repo_facts.txt)"
            Write-Output "--- tail of repo_facts.txt ---"
            Get-Content .\repo_facts.txt -Tail 200 | ForEach-Object { Write-Output $_ }
            break
        } else {
            Write-Warning "Script ran but repo_facts.txt not found in $c"
        }
    } catch { Write-Warning "Running script failed: $($_.Exception.Message)" }
}

Write-Output "Done. If no SUCCESS above, run the script from the correct project root manually."
