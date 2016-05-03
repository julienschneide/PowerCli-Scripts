$sdate = 01/04/2016
$fdate = 30/04/2016

$metrics_rp = "cpu.usagemhz.average", "mem.consumed.average", "mem.active.average", "mem.overhead.average"

$RPs = get-ResourcePool -Name dbi-services, dbi-prod, dbi-test -Location lssrvp01.arcentis.local

$stats = @()

foreach($RP in $RPs)
    {
     Write-Host "Collecting data for" $RP " resource pool..."
	 $stats += Get-Stat -Entity $RP -Stat $metrics_rp -Start 30/04/2016 -Finish 03/05/2016 -IntervalMins 86400
    }
	
$stats | Export-CSV -Path .\exports\RPPerf.csv -Force