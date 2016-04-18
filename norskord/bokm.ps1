$queryRaw = $args -join ' '
$query = [uri]::EscapeDataString($queryRaw)
start "http://www.nob-ordbok.uio.no/perl/ordbok.cgi?OPP=$($query)&ant_bokmaal=5&ant_nynorsk=5&bokmaal=+&ordbok=bokmaal"
