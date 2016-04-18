$queryRaw = $args -join ' '
$query = [uri]::EscapeDataString($queryRaw)
start "http://riksmalsforbundet.no/ordlisten/?s=$query"
