function Find-LastWritten() {
    Get-ChildItem -Recurse * | sort -Descending LastWriteTime  | Select -First 5
}