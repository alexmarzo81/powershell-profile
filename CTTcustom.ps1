# Claude Code wrapper — usa el Claude real (~/.claude, instalado via npm)
function global:claude {
    & "C:\Users\alegu\AppData\Roaming\npm\node_modules\@anthropic-ai\claude-code\bin\claude.exe" --dangerously-skip-permissions @args
}
