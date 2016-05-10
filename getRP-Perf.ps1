###########################################################
#   Scripts de récupération des statistiques VMware
###########################################################
# Auteur : Julien Schneider
# Date : 10.05.2016

###########################################################
# Importation des modules
###########################################################
Import-Module .\modules\Merge-CSVFiles.psm1 -Force

###########################################################
# Renseignement des variables du script par l'utilisateur
###########################################################
<#
if(($vCenter = Read-Host "Enter the vCenter IP address ") -eq ''){$vCenter = "10.10.2.10"}
if(($vCenterUser = Read-Host "Enter the username for the vCenter connection ") -eq ''){$vCenterUser = ""}
if(($vCenterPassword = Read-Host -assecurestring "Enter the password for the vCenter connection ") -eq ''){$vCenterPassword = ""}

if(($selectedHost = Read-Host "Enter the name of the host on which perform statistics collection ") -eq ''){$selectedHost = "lssrvp01.arcentis.local"}
if(($selectedRP = Read-Host "Enter the resources pools names ") -eq ''){$selectedRP = "dbi-services", "dbi-prod", "dbi-test"}
if(($metrics_rp = Read-Host "Enter metrics names ") -eq ''){$metrics_rp = "cpu.usagemhz.average", "mem.consumed.average", "mem.active.average", "mem.overhead.average"}

if(($sDate = Read-Host "Enter the start date for statistics collection ") -eq ''){$sDate = "01/04/2016"}
if(($fDate = Read-Host "Enter the end date for statistics collection ") -eq ''){$fDate = "30/04/2016"}
if(($interval = Read-Host "Enter the interval for statistics collection ") -eq ''){$interval = 86400}
#>

$selectedHost = "lssrvp01.arcentis.local"
$selectedRP = "dbi-services", "dbi-prod", "dbi-test"
$metrics_rp = "cpu.usagemhz.average", "mem.consumed.average", "mem.active.average"
$sDate = "01/04/2016"
$fDate = "30/04/2016"
$interval = 86400

###########################################################
# Début du script
###########################################################
#Connect-VIServer -Server $vCenter -Protocol https -User $vCenterUser -Password $vCenterPassword

$statistics = @()
$RPs = get-ResourcePool -Name $selectedRP -Location $selectedHost

foreach($RP in $RPs){
	Write-Host "Collecting data for" $RP " resource pool on" $selectedHost "Host..."
	
	$statistics = Get-Stat -Entity $RP -Stat $metrics_rp -Start $sDate -Finish $fDate -IntervalMins $interval | %{
		New-Object PSObject -Property @{
			Time = $_.Timestamp.ToString('dd.MM.yyyy')
			Host = $selectedHost
			"Resource Pool" = $_.Entity.Name
			Metric = $_.MetricId
			Value = $_.Value
			Unit = $_.Unit
			"CPU Limit" = $RP.CpuLimitMhz
			"Memory Limit" = $RP.MemLimitMB
			"CPU Share Level" = $RP.CpuSharesLevel
			"Memory Share Level" = $RP.MemSharesLevel
		}
	}
	$CSVOutDirectory = ".\exports\"+$selectedHost+"\"
	$CSVOutFileName = "Report_"+$RP.Name+".csv"
	$CSVOutPathFile = $CSVOutDirectory + $CSVOutFileName
	
	$statistics | 
			SELECT Time, Host, "Resource Pool", Metric, Value, Unit, "CPU Limit", "Memory Limit", "CPU Share Level", "Memory Share Level" |
			Sort-Object "Resource Pool", Metric, Time |
			Export-CSV -Path $CSVOutPathFile  -Force -NoTypeInformation
	
	$statistics = @()
}

$MonthYearDate = Get-Date -Format MMMM-yyyy
$XLSXOutPathFile = $PSScriptRoot + "\exports\"+$selectedHost+"\ExcelReport-" + $MonthYearDate + ".xlsx"
Merge-CSVFiles -CSVPath $CSVOutDirectory -XLOutput $XLSXOutPathFile

#Disconnect-VIServer $vCenter -Confirm:$false

###########################################################
# Export vers fichier CSV
###########################################################
<#$Resp = "lssrvp01-dbi"
$out_file = ".\exports\RPPerf_"+$Resp+".csv"

$statistics | 
			SELECT Time, Host, "Resource Pool", Metric, Value, Unit, "CPU Limit", "Memory Limit", "CPU Share Level", "Memory Share Level" |
			Sort-Object "Resource Pool", Metric, Time |
			Export-CSV -Path $out_file  -Force -NoTypeInformation
			
Invoke-Item $out_file

#>