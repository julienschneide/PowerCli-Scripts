###########################################################
#   Scripts de récupération des statistiques VMware
###########################################################

###########################################################
# Renseignement des variables du script
###########################################################
$selectedHost = "lssrvp01.arcentis.local"
$selectedRP = "dbi-services, dbi-prod, dbi-test"
$metrics_rp = "cpu.usagemhz.average", "mem.consumed.average", "mem.active.average", "mem.overhead.average"

$sDate = "01/04/2016"
$fDate = "03/05/2016"
$interval = 86400

###########################################################
# Début du script
###########################################################
$RPs = get-ResourcePool -Name $selectedRP -Location $selectedHost
Write-Host "get-ResourcePool -Name" $selectedRP "-Location" $selectedHost
$statistics = @()

foreach($RP in $RPs)
    {
     Write-Host "Collecting data for" $RP " resource pool..."
	 $statistics += Get-Stat -Entity $RP -Stat $metrics_rp -Start $sDate -Finish $fDate -IntervalMins $interval
    }
	
$statistics | SELECT Timestamp, Entity, MetricId, Unit, Value | Export-CSV -Path .\exports\RPPerf.csv -Force -NoTypeInformation