$vms=get-view -viewtype virtualmachine
$(
foreach($vm in $vms){
$networkcards=$vm.guest.net | ?{$_.DeviceConfigId -ne -1}
""|select  @{n="VM name";e={$vm.name}},@{n="uuid";e={$vm.config.uuid}},@{n="net  info";e={[string]::join(',',  $($networkcards|%{$devid=$_.DeviceConfigId;[string]::join(',',$(($vm.config.hardware.device|?{$_.key  -eq $devid}).gettype().name,$_.network,($_.ipaddress -join ';'),$_.Macaddress))})  )}}
}
)|export-csv .\exports\ListVMNetwork.csv