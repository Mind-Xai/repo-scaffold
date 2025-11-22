Set-StrictMode -Off
$ErrorActionPreference = 'Continue'

# Prefer git-detected root if available
$repoRoot = $null
try {
    $gitRoot = & git rev-parse --show-toplevel 2>$null
    if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($gitRoot)) {
        $repoRoot = $gitRoot.Trim()
    }
} catch { }

if (-not $repoRoot) { $repoRoot = (Get-Location).Path }

try { Set-Location -Path $repoRoot } catch { Write-Warning "Failed to Set-Location to $repoRoot; continuing in current location." }

$out = Join-Path -Path $repoRoot -ChildPath 'repo_facts.txt'
if (Test-Path $out) { Remove-Item $out -Force -ErrorAction SilentlyContinue }

# Manifest files to capture (do NOT include raw .env)
$files = @('README.md','package.json','pyproject.toml','go.mod','Cargo.toml','pom.xml','Dockerfile','docker-compose.yml','.env.example')

foreach ($f in $files) {
    try {
        $p = Join-Path $repoRoot $f
        if (Test-Path $p) {
            Add-Content -Path $out -Value ("`n===== FILE: $f =====`n")
            Get-Content -Path $p -Raw -ErrorAction Stop | Add-Content -Path $out
        }
    } catch {
        Write-Warning "Skipping $f: $($_.Exception.Message)"
    }
}

# Optional: include sanitized env if present
if (Test-Path (Join-Path $repoRoot '.env.share')) {
    try {
        Add-Content -Path $out -Value "`n===== FILE: .env.share (sanitized) =====`n"
        Get-Content -Path (Join-Path $repoRoot '.env.share') -Raw | Add-Content -Path $out
    } catch { Write-Warning "Failed reading .env.share" }
}

# Capture .github workflows
try {
    $wfDir = Join-Path $repoRoot '.github\workflows'
    if (Test-Path $wfDir) {
        Get-ChildItem -Path $wfDir -File -ErrorAction SilentlyContinue | ForEach-Object {
            try {
                Add-Content -Path $out -Value ("`n===== WORKFLOW: .github/workflows/$($_.Name) =====`n")
                Get-Content -Path $_.FullName -Raw -ErrorAction Stop | Add-Content -Path $out
            } catch { Write-Warning "Skipping workflow $($_.Name): $($_.Exception.Message)" }
        }
    }
} catch { }

# Find common schema/codegen files (safe recursive searches, non-greedy)
try {
    Get-ChildItem -Path $repoRoot -Recurse -Force -ErrorAction SilentlyContinue -Include *.proto,openapi*.yml,openapi*.yaml,swagger*.yml,swagger*.yaml | ForEach-Object {
        try {
            Add-Content -Path $out -Value ("`n===== SCHEMA: $($_.FullName) =====`n")
            Get-Content -Path $_.FullName -Raw -ErrorAction Stop | Add-Content -Path $out
        } catch { Write-Warning "Skipping schema $($_.FullName): $($_.Exception.Message)" }
    }
} catch { }

# Top-level listing (exclude large/hidden tooling dirs)
try {
    Add-Content -Path $out -Value "`n===== TOP-LEVEL FILES & DIRECTORIES =====`n"
    Get-ChildItem -Path $repoRoot -Force | Where-Object { -not ($_.Name.StartsWith('.') -or $_.Name -in @('node_modules','.venv','venv')) } | Select-Object Name,Mode | Out-String | Add-Content -Path $out
} catch { Write-Warning "Failed listing top-level files: $($_.Exception.Message)" }

# Git tracked files (top 200) if git available
try {
    $isGit = (& git rev-parse --is-inside-work-tree 2>$null) -eq 'true'
    if ($isGit) {
        Add-Content -Path $out -Value "`n===== GIT TRACKED FILES (top 200) =====`n"
        (& git ls-files | Select-Object -First 200) -join "`n" | Add-Content -Path $out
    }
} catch { }

Write-Output "Collected repo facts to: $out"
