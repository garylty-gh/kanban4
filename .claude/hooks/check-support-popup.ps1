# PostToolUse guard: after Claude edits index.html, check that the
# 10-second IT support hotline popup is still intact. If any part is
# missing, the reason is fed back to Claude so it restores it.

$ErrorActionPreference = "Stop"

try {
    $payload = [Console]::In.ReadToEnd() | ConvertFrom-Json
} catch {
    exit 0  # unreadable input: never block Claude over the guard itself
}

$filePath = $payload.tool_input.file_path
if (-not $filePath -or (Split-Path $filePath -Leaf) -ne "index.html") { exit 0 }
if (-not (Test-Path $filePath)) { exit 0 }

$html = Get-Content -Raw -Encoding UTF8 $filePath

$checks = [ordered]@{
    'popup markup (id="help-backdrop" dialog)'          = 'id="help-backdrop"'
    'dialog role on the popup'                          = 'aria-labelledby="help-title"'
    'hotline link (href="tel:12345678")'                = 'href="tel:12345678"'
    '10-second delay (HELP_NOTICE_DELAY_MS = 10000)'    = 'HELP_NOTICE_DELAY_MS\s*=\s*10000'
    'timer start (setTimeout(showHelpNotice, ...))'     = 'setTimeout\(\s*showHelpNotice\s*,\s*HELP_NOTICE_DELAY_MS'
    'close handler (closeHelpNotice)'                   = 'function\s+closeHelpNotice'
}

$missing = @()
foreach ($name in $checks.Keys) {
    if ($html -notmatch $checks[$name]) { $missing += $name }
}

if ($missing.Count -eq 0) { exit 0 }

$reason = "index.html no longer has the full IT support hotline popup " +
    "(shown after 10 seconds on the page, hotline 12345678). Missing: " +
    ($missing -join "; ") + ". Restore it unless the user asked to remove it."

@{ decision = "block"; reason = $reason } | ConvertTo-Json -Compress
exit 0
