﻿<#PSScriptInfo

.VERSION 1.0.0.1

.GUID 17b1a674-c1bb-44e0-b113-630397db8e11

.AUTHOR matt.quickenden

.COMPANYNAME ACE

.COPYRIGHT 

.TAGS ReportHTML 

.LICENSEURI 

.PROJECTURI http://www.azurefieldnotes.com/2016/08/04/powershellhtmlreportingpart1/

.ICONURI 

.EXTERNALMODULEDEPENDENCIES ReportHTML 1.0.0.9

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES


#>

<# 

.DESCRIPTION 
 A computer system report, this was generated from https://www.simple-talk.com/sysadmin/powershell/building-a-daily-systems-report-email-with-powershell/ using the ReportHTML module details here. http://www.azurefieldnotes.com/2016/08/04/powershellhtmlreportingpart1/

#> 
param (
	$ReportOutputPath,
	$ReportName = "ACE Systems Report",
    $thresholdspace = 20,
    [int]$EventNum = 5,
    [int]$ProccessNumToFetch = 10,
	#$users = "youremail@yourcompany.com", # List of users to email your report to (separate by comma)
    #$fromemail = "youremail@yourcompany.com",
    #$server = "yourmailserver.yourcompany.com", #enter your own SMTP server DNS name / IP address here
    $list = $args[0] #This accepts the argument you add to your scheduled task for the list of servers. i.e. list.txt
)

#region ReportHelpers
Function Test-Report 
{
	param (
		$TestName,
		$HTMLReport
	)
	$rptFile = join-path $ReportOutputPath ($ReportName.replace(" ","") + "-$TestName" + ".mht")
	$HTMLReport | Set-Content -Path $rptFile -Force
   	sleep 1
   	Invoke-Item $rptFile
}

Function Import-ReportHTML {
Param (
	[Version]$version
)
	try {Import-Module ReportHtml}
	catch {Write-error "Install ReportHTML module.  Install-module -name ReportHTML. Details here http://www.azurefieldnotes.com/2016/08/04/powershellhtmlreportingpart1/"}
	finally {
		$RMV= (get-module | ? {$_.name -eq 'ReportHTML'}).version 
		if ($RMV -ge $version) {
			Write-Output "ReportHTML module Version $RMV found"
		} else {
			write-output "Pretty please update the ReportHTML module.  Update-module -name ReportHTML"
		}
	}
}
#endregion
Import-ReportHTML -version '1.0.0.11'

#Region Logos
#convert required image to Base64 and put strings here
$Logo1 = "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"
$logo2 = "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"
#endregion
if (!$ReportOutputPath)  {$ReportOutputPath = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent} 

$Report = @()
$computers = @(get-content $list) | sort  #grab the names of the servers/computers to check from the list.txt file.
if ($computers.count -eq 0) {
	Write-Warning "List empty selecting localhost $env:computername"
	$Computers = @($env:computername)
}

Function Get-HostUptime {
    param ([string]$ComputerName)
    $Uptime = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $ComputerName
    $LastBootUpTime = $Uptime.ConvertToDateTime($Uptime.LastBootUpTime)
    $Time = (Get-Date) - $LastBootUpTime
    Return '{0:00} Days, {1:00} Hours, {2:00} Minutes, {3:00} Seconds' -f $Time.Days, $Time.Hours, $Time.Minutes, $Time.Seconds
}


$Report += Get-HtmlOpen  -TitleText ($ReportName)

foreach ($computer in $computers){
	$Report += Get-HtmlContentOpen -IsHidden -HeaderText "System Report For - $computer"	 -BackgroundShade 2
	
	#Region System & Disk 
    $DiskInfo= Get-WMIObject -ComputerName $computer Win32_LogicalDisk | Where-Object{$_.DriveType -eq 3} | Where-Object{ ($_.freespace/$_.Size)*100 -lt $thresholdspace} `
	    | Select-Object SystemName, DriveType, VolumeName, Name, @{n='Size (GB)';e={"{0:n2}" -f ($_.size/1gb)}}, @{n='FreeSpace (GB)';e={"{0:n2}" -f ($_.freespace/1gb)}}, @{n='PercentFree';e={"{0:n2}" -f ($_.freespace/$_.size*100)}} #| ConvertTo-HTML -fragment
	$SystemInfo = (Get-WmiObject -Class Win32_OperatingSystem -computername $computer | Select-Object Name, TotalVisibleMemorySize, FreePhysicalMemory)
	$TotalRAM = ($SystemInfo.TotalVisibleMemorySize/1MB)
	$FreeRAM =($SystemInfo.FreePhysicalMemory/1MB)
	$UsedRAM =($TotalRAM - $FreeRAM)
	$RAMPercentFree = ($FreeRAM / $TotalRAM) * 100
	
	$Report += Get-HtmlContentOpen -HeaderText "System Information" -BackgroundShade 1
		$Report += Get-HTMLColumn1of2
			$Report += Get-HtmlContentOpen -HeaderText "OS Information"
				$Report += Get-HtmlContentText -Heading "OS" -Detail (Get-WmiObject Win32_OperatingSystem -computername $computer).caption
				$Report += Get-HtmlContentText -Heading "Uptime" -Detail (Get-HostUptime -ComputerName $computer)
			    $Report += Get-HtmlContentText -Heading "Total RAM" -detail ([Math]::Round($TotalRAM, 2))
			    $Report += Get-HtmlContentText -Heading "Free RAM" -detail ([Math]::Round($FreeRAM, 2))
			    $Report += Get-HtmlContentText -Heading "Used RAM" -Detail ( [Math]::Round($UsedRAM, 2))
			    $Report += Get-HtmlContentText -Heading "RAM Free %" -Detail ( [Math]::Round($RAMPercentFree, 2))
			$Report += Get-HtmlContentClose
			
			$Report += Get-HtmlContentOpen -HeaderText "Disk Information"
				$Report += Get-HtmlContentTable $DiskInfo
			$Report += Get-HtmlContentClose
		$Report += Get-HTMLColumnClose
		
		$Report += Get-HTMLColumn2of2
			$PieChartObject = New-HTMLPieChartObject      
			$PieChartObject.Title = "Disk Space"
			$PieChartObject.Size.Width = 400
			#$PieChartObject.ChartStyle.ExplodeMaxValue = $true  
			$DiskSpace = @();$DiskSpaceRecord = '' | select Name, Count
			$DiskSpaceRecord.Count = $DiskInfo.'FreeSpace (GB)';$DiskSpaceRecord.Name = "Free (GB)"
			$DiskSpace += $DiskSpaceRecord;$DiskSpaceRecord = '' | select Name, Count
			$DiskSpaceRecord.Count = $DiskInfo.'Size (GB)' -  $DiskInfo.'FreeSpace (GB)';$DiskSpaceRecord.Name = "Used (GB)"
			$DiskSpace += $DiskSpaceRecord
			$Report += New-HTMLPieChart -PieChartObject $PieChartObject -PieChartData ($DiskSpace)
		$Report += Get-HTMLColumnClose
	$Report += Get-HtmlContentClose
    #endregion
    
	#Region Services & Processes
	$Report += Get-HtmlContentOpen -HeaderText "Processes & Services" -IsHidden
		$Report += Get-HTMLColumn1of2
			$TopProcesses = Get-Process -ComputerName $computer | Sort WS -Descending | Select ProcessName, Id, WS -First $ProccessNumToFetch #| ConvertTo-Html -Fragment
	    	$Report +=  Get-HtmlContentTable $TopProcesses
		$Report += Get-HtmlColumnClose
		
		$ServicesReport = @()
	    $Services = Get-WmiObject -Class Win32_Service -ComputerName $computer | Where {($_.StartMode -eq "Auto") -and ($_.State -eq "Stopped")}
	    foreach ($Service in $Services) {
	        $row = New-Object -Type PSObject -Property @{
	               Name = $Service.Name
	            Status = $Service.State
	            StartMode = $Service.StartMode
	        }
	    $ServicesReport += $row
	    }
		$Report += Get-HTMLColumn2of2
			$Report += Get-HtmlContentTable $ServicesReport
		$Report += Get-HtmlColumnClose
   	$Report += Get-HtmlContentclose
    #endregion
        
    #region Event Logs Report
		
	$Appevents = Get-EventLog -ComputerName $computer -LogName Application -EntryType Error   | group  Source | sort count -Descending | select -First 5
	$Sysevents = Get-EventLog -ComputerName $computer -LogName System -EntryType Error   | group  Source | sort count -Descending | select -First 5

	$Report += Get-HtmlContentOpen -HeaderText "Event Logs" 
		$Report += Get-HtmlContentOpen -HeaderText "Top 5 Sources of Errors" 
		$Report +=  Get-HTMLColumn1of2
			$PieChartObject = New-HTMLPieChartObject      
			$PieChartObject.Title = "System Log Top 5 Errors"
			$PieChartObject.Size.Width = 600
			$PieChartObject.Size.Height =400
			$Report += New-HTMLPieChart -PieChartObject $PieChartObject -PieChartData ($Appevents)
			$Report += Get-HtmlContentTable (Set-TableRowColor ( $Appevents | select name, count) -alternating  )
		$Report += Get-HtmlColumnClose
		$Report +=  Get-HTMLColumn1of2
			$PieChartObject = New-HTMLPieChartObject      
			$PieChartObject.Title = "Application Log 5 Errors"
			$PieChartObject.Size.Width = 600
			$PieChartObject.Size.Height =400
			$Report += New-HTMLPieChart -PieChartObject $PieChartObject -PieChartData ($Sysevents)
			$Report += Get-HtmlContentTable (Set-TableRowColor ($Sysevents | select name, count) -alternating  )
		$Report += Get-HtmlColumnClose
		$Report += Get-HtmlContentClose
			
		    $SystemEventsReport = @()
		    $SystemEvents = Get-EventLog -ComputerName $computer -LogName System -EntryType Error -Newest $EventNum
		    foreach ($event in $SystemEvents) {
		        $row = New-Object -Type PSObject -Property @{
		            TimeGenerated = $event.TimeGenerated
		            EntryType = $event.EntryType
		            Source = $event.Source
		            Message = $event.Message
		        }
		        $SystemEventsReport += $row
		    }
		    $Report += Get-HtmlContentOpen -HeaderText "System Event Log" -IsHidden
				$Report += Get-HtmlContentTable $SystemEventsReport 
			$Report += Get-HtmlContentClose
		    #$SystemEventsReport = $SystemEventsReport | ConvertTo-Html -Fragment
		    
		    $ApplicationEventsReport = @()
		    $ApplicationEvents = Get-EventLog -ComputerName $computer -LogName Application -EntryType Error -Newest $EventNum
		    foreach ($event in $ApplicationEvents) {
		        $row = New-Object -Type PSObject -Property @{
		            TimeGenerated = $event.TimeGenerated
		            EntryType = $event.EntryType
		            Source = $event.Source
		            Message = $event.Message
		        }
		        $ApplicationEventsReport += $row
		    }
			$Report += Get-HtmlContentOpen -HeaderText "Application Event Log" -IsHidden
				$Report += Get-HtmlContentTable $ApplicationEventsReport 
			$Report += Get-HtmlContentClose
		
    #$ApplicationEventsReport = $ApplicationEventsReport | ConvertTo-Html -Fragment
    #endregion
    
    # Create the chart using our Chart Function
    #Create-PieChart -FileName ((Get-Location).Path + "\chart-$computer") $FreeRAM, $UsedRAM
	$Report += Get-HtmlContentClose
}


$Report += Get-HtmlContentClose
$Report += Get-HtmlClose -AdditionalContent $Logo1 -ClientLogoType $logo2
 
Test-Report -TestName SystemsReport -HTMLReport $Report


## Assemble the final report from all our HTML sections
#$HTMLmessage = $HTMLHeader + $HTMLMiddle + $HTMLEnd
## Save the report out to a file in the current path
#$HTMLmessage | Out-File ((Get-Location).Path + "\report.html")
## Email our report out
#send-mailmessage -from $fromemail -to $users -subject "Systems Report" -Attachments $ListOfAttachments -BodyAsHTML -body $HTMLmessage -priority Normal -smtpServer $server




