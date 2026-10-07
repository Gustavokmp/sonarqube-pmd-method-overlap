$base = "sources/spring-framework-6.2.16"
$modules = @(
  "spring-aop",
  "spring-aspects",
  "spring-beans",
  "spring-context",
  "spring-context-indexer",
  "spring-context-support",
  "spring-core",
  "spring-core-test",
  "spring-expression",
  "spring-instrument",
  "spring-jcl",
  "spring-jdbc",
  "spring-jms",
  "spring-messaging",
  "spring-orm",
  "spring-oxm",
  "spring-r2dbc",
  "spring-test",
  "spring-tx",
  "spring-web",
  "spring-webflux",
  "spring-webmvc",
  "spring-websocket"
)
$dirs = ($modules | ForEach-Object { "$base/$_/src/main/java" }) -join ","
# Caso especial MRJAR do spring-core.
$dirs += ",$base/spring-core/src/main/java21"

$outXml = "runs/spring-framework-6.2.16-2026-10-01/raw/pmd-output.xml"
$outLog = "runs/spring-framework-6.2.16-2026-10-01/logs/pmd-output.txt"
New-Item -ItemType Directory -Force -Path (Split-Path $outXml) | Out-Null

& "sources/pmd-bin-7.27.0/bin/pmd.bat" check `
  -d $dirs `
  -R "configs/pmd-ruleset-exp-mestrado-long-smells.xml" `
  -f xml -r $outXml --no-cache *>&1 | Tee-Object -FilePath $outLog
"EXITCODE=$LASTEXITCODE" | Out-File -FilePath $outLog -Append -Encoding utf8
