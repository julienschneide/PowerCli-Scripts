$selectedHost = "lssrvp01.arcentis.local"
$selectedRP = "dbi-services", "dbi-prod", "dbi-test"
$RP = "dbi-services"
$metrics_rp = "cpu.usagemhz.average", "mem.consumed.average", "mem.active.average", "mem.overhead.average"
$sDate = "30/04/2016"
$fDate = "03/05/2016"
$interval = 43200


###########################################################
# Début du script
###########################################################

	$statistics += Get-StatType -Entity $RP
$out_file = ".\exports\try.csv"

$statistics | Export-CSV -Path $out_file -Force -NoTypeInformation