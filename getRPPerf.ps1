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

foreach($RP in $RPs){
		Write-Host "Collecting data for" $RP " resource pool on" $selectedHost "Host..."
		
		$statistics += Get-Stat -Entity $RP -Stat $metrics_rp -Start $sDate -Finish $fDate -IntervalMins $interval | %{
			New-Object PSObject -Property @{
				Time = $_.Timestamp
				Host = $selectedHost
				"Resource Pool" = $_.Entity.Name
				Metric = $_.MetricId
				Value = $_.Value
				Unit = $_.Unit
				"CPU Limit" = $RP.CpuLimitMhz
				"Memory Limit" = $RP.MemLimitMB
			}
		}
		
    }
	
###########################################################
# Export vers fichier CSV
###########################################################
$statistics | 
			SELECT Time, Host, "Resource Pool", Metric, Value, Unit, "CPU Limit", "Memory Limit" |
			Sort-Object "Resource Pool", Metric, Time |
			Export-CSV -Path .\exports\RPPerf.csv -Force -NoTypeInformation