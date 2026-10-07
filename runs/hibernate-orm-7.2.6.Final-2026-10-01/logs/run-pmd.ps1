$base = "sources/hibernate-orm-7.2.6.Final"
$modules = @(
  "hibernate-core",
  "hibernate-envers",
  "hibernate-spatial",
  "hibernate-community-dialects",
  "hibernate-vector",
  "hibernate-c3p0",
  "hibernate-hikaricp",
  "hibernate-agroal",
  "hibernate-jcache",
  "hibernate-micrometer",
  "hibernate-graalvm",
  "hibernate-jfr",
  "hibernate-scan-jandex",
  "tooling/metamodel-generator",
  "tooling/hibernate-gradle-plugin",
  "tooling/hibernate-maven-plugin",
  "tooling/hibernate-ant"
)
$dirs = ($modules | ForEach-Object { "$base/$_/src/main/java" }) -join ","

$outXml = "runs/hibernate-orm-7.2.6.Final-2026-10-01/raw/pmd-output.xml"
$outLog = "runs/hibernate-orm-7.2.6.Final-2026-10-01/logs/pmd-output.txt"
New-Item -ItemType Directory -Force -Path (Split-Path $outXml) | Out-Null

& "sources/pmd-bin-7.27.0/bin/pmd.bat" check `
  -d $dirs `
  -R "configs/pmd-ruleset-exp-mestrado-long-smells.xml" `
  -f xml -r $outXml --no-cache *>&1 | Tee-Object -FilePath $outLog
"EXITCODE=$LASTEXITCODE" | Out-File -FilePath $outLog -Append -Encoding utf8
