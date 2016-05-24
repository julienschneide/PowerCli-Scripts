###########################################################
#   Scripts de récupération des statistiques VMware
###########################################################
# Auteur 			   : Julien Schneider
# Date de modification : 24.05.2016

Clear-Host

Write-Host "
********************************
**   VMware Capacity Report   **
********************************
"

###########################################################
# Loading PowerCli Environment
###########################################################
if (Get-PSSnapin vmware* -ErrorAction SilentlyContinue) {
	Write-Host "vSphere snapin already loaded, proceeding."
} else {
	Write-Host "Loading vSphere snapin."
	Add-pssnapin VMWare.VimAutomation.Core -ErrorAction SilentlyContinue
	if (Get-PSSnapin vmware* -ErrorAction SilentlyContinue) {
		Write-Host "vSphere snapin loaded"
	} else {
		Write-Host -ForegroundColor Red "Error loading vSphere snapin. Halting."
		Write-Host -ForegroundColor Red "VMware PowerCLI is required to run this script."
		break
	}
}
write-host "`n"

###########################################################
# Importation des modules
###########################################################
Import-Module .\modules\Merge-CSVFiles.psm1 -Force

###########################################################
# Renseignement des variables du script par l'utilisateur
###########################################################

# Connexion au server vCenter :
# !! a réactiver if(($vCenterIP = Read-Host "Enter the vCenter IP address ") -eq ''){$vCenter = ""}

# Import d'un fichier de configuration :
. .\conf\config1.ps1


<#
if(($selectedHost = Read-Host "Enter the name of the host on which perform statistics collection ") -eq ''){$selectedHost = "lssrvp01.arcentis.local"}
if(($selectedRP = Read-Host "Enter the resources pools names ") -eq ''){$selectedRP = "dbi-services", "dbi-prod", "dbi-test"}
if(($metrics_rp = Read-Host "Enter metrics names ") -eq ''){$metrics_rp = "cpu.usagemhz.average", "mem.consumed.average", "mem.active.average", "mem.overhead.average"}

if(($sDate = Read-Host "Enter the start date for statistics collection ") -eq ''){$sDate = "01/04/2016"}
if(($fDate = Read-Host "Enter the end date for statistics collection ") -eq ''){$fDate = "30/04/2016"}
if(($interval = Read-Host "Enter the interval for statistics collection ") -eq ''){$interval = 86400}

$selectedHost = "lssrvp01.arcentis.local"
$selectedRP = "dbi-services", "dbi-prod", "dbi-test"
$metrics_rp = "cpu.usagemhz.average", "mem.consumed.average", "mem.active.average"
$sDate = "01/04/2016"
$fDate = "30/04/2016"
$interval = 86400
#>

###########################################################
# Début du script
###########################################################

# !! a réactiver Connect-VIServer -Server $vCenterIP


Write-Host "Please wait while we attempt to connect to $vCenterIP ..."
write-host "`n"

$statistics = @()
$RPs = get-ResourcePool -Name $selectedRP -Location $selectedHost

foreach($RP in $RPs){
	Write-Host "Collecting data for" $RP " resource pool on" $selectedHost "Host..."
	
	$statistics = Get-Stat -Entity $RP -Stat $metrics_rp -Start $sDate -Finish $fDate -IntervalSecs $interval | %{
	
		if($_.MetricId.StartsWith("mem.")){
			$MetricValue = [math]::Round(($_.Value / 1024), 2)
			$MetricUnit = "MB"
		} else {
			$MetricValue = $_.Value
			$MetricUnit = $_.Unit
		}
		
		New-Object PSObject -Property @{
			# Time = $_.Timestamp.ToString('dd.MM.yyyy')
			Time = $_.Timestamp
			Host = $selectedHost
			"Resource Pool" = $_.Entity.Name
			Metric = $_.MetricId
			Value = $MetricValue
			Unit = $MetricUnit
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

write-host "`n"

$MonthYearDate = Get-Date -Format MMMM-yyyy
$XLSXOutPathFile = $PSScriptRoot + "\exports\"+$selectedHost+"\ExcelReport-" + $MonthYearDate + ".xlsx"

Merge-CSVFiles -CSVPath $CSVOutDirectory -XLOutput $XLSXOutPathFile

write-host "`n"
write-host Excel file exported at $XLSXOutPathFile

Invoke-Item $XLSXOutPathFile

# !! a réactiver Disconnect-VIServer $vCenterIP -Confirm:$false