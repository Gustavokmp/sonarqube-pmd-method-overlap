# Gera o SHA256SUMS.txt (formato compatível com `sha256sum -c`) com os hashes de
# todos os arquivos versionados do repositório, inclusive do pacote .zip.
# Deve ser executado depois de scripts/export-package.ps1.
#
# Uso (a partir de qualquer diretório): ./scripts/generate-checksums.ps1

$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
Set-Location $repoRoot

$files = & git -c core.quotepath=off ls-files --cached --others --exclude-standard |
    Where-Object { $_ -and $_ -ne "SHA256SUMS.txt" } |
    Sort-Object -Unique

$lines = foreach ($f in $files) {
    $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $repoRoot ($f -replace '/', '\'))).Hash.ToLower()
    "$hash  $f"
}

$out = Join-Path $repoRoot "SHA256SUMS.txt"
[System.IO.File]::WriteAllText($out, (($lines -join "`n") + "`n"), (New-Object System.Text.UTF8Encoding($false)))
Write-Output "ARQUIVOS=$($files.Count) SAIDA=$out"