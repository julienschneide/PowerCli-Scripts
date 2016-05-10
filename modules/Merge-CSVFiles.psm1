Function Merge-CSVFiles{
	Param(
	$CSVPath = "", ## Soruce CSV Folder
	$XLOutput="" ## Output file name
)
	if($CSVPath -eq '' -Or $XLOutput -eq ''){
			Write-Host -foregroundcolor Red "Please, enter parameters for CSV files path and Excel output file path."
			return
	}
	
	$csvFiles = Get-ChildItem ("$CSVPath\*") -Include *.csv
	
	Write-Host Detected the following CSV files: ($csvFiles.Count)
	
	foreach ($csvFile in $csvFiles)
	{
	Write-Host "- " + $csvFile.Name
	}

	$Excel = New-Object -ComObject excel.application 
	$Excel.visible = $false
	$Excel.sheetsInNewWorkbook = $csvFiles.Count
	$workbooks = $excel.Workbooks.Add()
	$CSVSheet = 1

	Foreach ($CSV in $Csvfiles){
		$worksheets = $workbooks.worksheets
		$CSVFullPath = $CSV.FullName
		$SheetName = ($CSV.name -split "\.")[0]
		$worksheet = $worksheets.Item($CSVSheet)
		$worksheet.Name = $SheetName
		$TxtConnector = ("TEXT;" + $CSVFullPath)
		$CellRef = $worksheet.Range("A1")
		$Connector = $worksheet.QueryTables.add($TxtConnector,$CellRef)
		$worksheet.QueryTables.item($Connector.name).TextFileCommaDelimiter = $True
		$worksheet.QueryTables.item($Connector.name).TextFileParseType  = 1
		$worksheet.QueryTables.item($Connector.name).Refresh() | Out-Null
		$worksheet.QueryTables.item($Connector.name).delete() | Out-Null
		$worksheet.UsedRange.EntireColumn.AutoFit() | Out-Null
		$CSVSheet++
	}

	$workbooks.SaveAs($XLOutput)
	$workbooks.Saved = $True
	$workbooks.Close()
	[System.Runtime.Interopservices.Marshal]::ReleaseComObject($workbooks) | Out-Null
	$excel.Quit()
	[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
	[System.GC]::Collect()
	[System.GC]::WaitForPendingFinalizers()
}