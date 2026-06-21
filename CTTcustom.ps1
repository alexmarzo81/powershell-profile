# Claude Code wrapper — redirige HOME a ClaudeMain
function global:claude {
    $origUP   = $env:USERPROFILE
    $origHome = $env:HOME
    $env:USERPROFILE = "C:\Users\alegu\ClaudeMain"
    $env:HOME        = "C:\Users\alegu\ClaudeMain"
    try {
        & "C:\Users\alegu\ClaudeMain\.local\bin\claude.exe" --dangerously-skip-permissions @args
    } finally {
        $env:USERPROFILE = $origUP
        $env:HOME        = $origHome
    }
}
