###########################################################
#   Scripts de récupération des statistiques VMware
###########################################################

###########################################################
# Renseignement des variables du script
###########################################################
$statistics = @()

$selectedHost = "lssrvp01.arcentis.local"
$selectedRP = "dbi-services", "dbi-prod", "dbi-test"
$metrics_rp = "cpu.usagemhz.average", "mem.consumed.average", "mem.active.average", "mem.overhead.average"

$sDate = "01/04/2016"
$fDate = "30/04/2016"
$interval = 86400

###########################################################
# Début du script
###########################################################
$RPs = get-ResourcePool -Name $selectedRP -Location $selectedHost

foreach($RP in $RPs)
    {
	#$RPstat = "" | SELECT CpuLimitMhz, MemLimitMB
	#$RPstat.CpuLimitMhz = $RP.CpuLimitMhz
	 
	 
	Write-Host "Collecting data for" $RP " resource pool on" $selectedHost "Host..."
	$statistics += Get-Stat -Entity $RP -Stat $metrics_rp -Start $sDate -Finish $fDate -IntervalMins $interval
	#$statistics += $RPstat
	Write-Host "CPU Limit Mhz :" $RP.CpuLimitMhz
	Write-Host "CPU Reservation Mhz :" $RP.CpuReservationMhz
	Write-Host "Memory Limit MB" $RP.MemLimitMB
	Write-Host "Memory Reservation Limit MB" $RP.MemReservationMB
    }
	
#$statistics | SELECT Timestamp, Entity, MetricId, Unit, Value | Export-CSV -Path .\exports\RPPerf.csv -Force -NoTypeInformation
$statistics | Sort-Object Entity, MetricId, Timestamp | Export-CSV -Path .\exports\RPPerf.csv -Force -NoTypeInformation