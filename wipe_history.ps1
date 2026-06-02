# Wipe all git history and push a fresh initial commit to origin
# WARNING: This permanently replaces remote history. All collaborators must re-clone.

param(
    [switch]$AutoYes
)

Write-Host "This script will permanently remove all git history and push a fresh initial commit to the remote." -ForegroundColor Yellow
if (-not $AutoYes) {
    $ok = Read-Host "Type YES to proceed"
    if ($ok -ne 'YES') { Write-Host "Aborted." -ForegroundColor Red; exit 1 }
} else {
    Write-Host "Auto-confirm enabled (-AutoYes). Proceeding without interactive prompt." -ForegroundColor Yellow
}

if (-not (git rev-parse --is-inside-work-tree 2>$null)) {
    Write-Host "Not inside a git repository. Run this from the repository root." -ForegroundColor Red
    exit 1
}

# Capture remote URL
$remote = git config --get remote.origin.url
if (-not $remote) {
    $remote = Read-Host "No origin remote found. Enter remote URL to push to (https://...)"
    if (-not $remote) { Write-Host "No remote specified, aborting." -ForegroundColor Red; exit 1 }
}

# Backup .git
$backup = ".git_backup_$(Get-Date -Format yyyyMMddHHmmss)"
Write-Host "Backing up .git to $backup"
Rename-Item -Path .git -NewName $backup

# Re-init repo
git init

# Ensure we don't accidentally include backup in commit
Add-Content -Path .gitignore -Value "$backup/"
Add-Content -Path .gitignore -Value ".venv/"
Add-Content -Path .gitignore -Value "__pycache__/"

git add -A
git commit -m "Initial commit - repository history scrubbed on $(Get-Date -Format o)"

git remote add origin $remote

# Determine branch name to push (use master if remote had master previously)
$branch = 'master'
Write-Host "Setting branch to $branch"
git branch -M $branch

Write-Host "Force-pushing new history to origin/$branch"
git push --force --set-upstream origin $branch

# Delete remote branches (except the new branch) if possible
Write-Host "Attempting to delete other remote branches..."
$remoteBranches = git ls-remote --heads origin | ForEach-Object { ($_ -split "\t")[1] -replace 'refs/heads/','' }
foreach ($b in $remoteBranches) {
    if ($b -ne $branch) {
        Write-Host "Deleting remote branch: $b"
        git push origin --delete $b
    }
}

# Delete remote tags
Write-Host "Deleting remote tags..."
$tags = git ls-remote --tags origin | ForEach-Object { ($_ -split "\t")[1] } | ForEach-Object { if ($_ -match 'refs/tags/(.+)$') { $matches[1] } }
foreach ($t in $tags) {
    if ($t) {
        Write-Host "Deleting remote tag: $t"
        git push origin :refs/tags/$t
    }
}

Write-Host 'Done. Remote history should be replaced. Recommend re-cloning into a fresh folder to verify.' -ForegroundColor Green
Write-Host 'Important: Ensure any deployed services or CI that used old commit SHAs are updated.' -ForegroundColor Yellow
