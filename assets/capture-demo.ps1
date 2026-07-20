$chrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$html = "file:///C:/Users/revin/Desktop/revinnnn/mcp-debugger/assets/demo.html"
$out = "C:/Users/revin/Desktop/revinnnn/mcp-debugger/assets/demo.png"

$tmp = Join-Path $env:TEMP "demo_temp.png"

$args = @(
  "--headless=new"
  "--disable-gpu"
  "--hide-scrollbars"
  "--no-sandbox"
  "--window-size=1080,820"
  "--screenshot=$tmp"
  $html
)

$proc = Start-Process -FilePath $chrome -ArgumentList $args -Wait -PassThru -NoNewWindow
Start-Sleep -Milliseconds 500

if (Test-Path $tmp) {
  Copy-Item $tmp $out -Force
  $info = Get-Item $out
  Write-Host ("[OK] demo.png saved")
  Write-Host ("    path: " + $info.FullName)
  Write-Host ("    size: " + [math]::Round($info.Length / 1KB, 1) + " KB")
  Write-Host ("    dims: " + $info.Width + "x" + $info.Height)
  Remove-Item $tmp -Force -ErrorAction SilentlyContinue
} else {
  Write-Host "[FAIL] Chrome did not produce the screenshot"
  Write-Host "chrome exit code:" $proc.ExitCode
}
