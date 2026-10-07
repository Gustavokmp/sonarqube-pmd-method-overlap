# Monta o pacote exportável do experimento (PROTOCOLO.md seção 24): um .zip com
# os arquivos versionados do repositório (lista obtida do Git), com caminhos
# internos portáveis ("/"), sem credenciais, caches, volumes Docker, dependências
# baixadas ou sources/ (re-clonável, ignorado pelo Git).
#
# Não inclui o próprio .zip nem o SHA256SUMS.txt (gerado depois por
# scripts/generate-checksums.ps1).
#
# Uso (a partir de qualquer diretório): ./scripts/export-package.ps1

$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
Set-Location $repoRoot

$zipRel = "results/consolidado-2026-10-01/exp-mestrado-pacote-exportavel-2026-10-01.zip"
$zipPath = Join-Path $repoRoot $zipRel
$files = & git -c core.quotepath=off ls-files --cached --others --exclude-standard |
    Where-Object { $_ -and $_ -ne $zipRel -and $_ -ne "SHA256SUMS.txt" } |
    Sort-Object -Unique

# Validação: nenhuma credencial (.env / .env.*, exceto .env.example) no pacote.
$leaked = $files | Where-Object { $_ -match '(^|/)\.env(\..+)?$' -and $_ -notmatch '(^|/)\.env\.example$' }
if ($leaked) {
    throw "Vazamento de credenciais detectado no pacote: $($leaked -join ', ')"
}

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

if (Test-Path $zipPath) { Remove-Item -Force $zipPath }
$zip = [System.IO.Compression.ZipFile]::Open($zipPath, [System.IO.Compression.ZipArchiveMode]::Create)
try {
    foreach ($f in $files) {
        $src = Join-Path $repoRoot ($f -replace '/', '\')
        [void][System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $src, $f, [System.IO.Compression.CompressionLevel]::Optimal)
    }
} finally {
    $zip.Dispose()
}

Write-Output "PACKAGE=$zipPath"
Write-Output "FILES=$($files.Count)"
Write-Output "SIZE_MB=$([math]::Round((Get-Item $zipPath).Length / 1MB, 2))"