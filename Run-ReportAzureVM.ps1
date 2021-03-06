<#PSScriptInfo

.VERSION 1.0.0.5

.GUID 8b4bead7-6644-4ba4-b59b-daec7ea7e28b

.AUTHOR Matthew Quickenden

.COMPANYNAME ACE

.COPYRIGHT 

.TAGS Report HTML Azure IaaS

.LICENSEURI 

.PROJECTURI https://github.com/azurefieldnotes/Reports

.ICONURI https://azurefieldnotesblog.blob.core.windows.net/wp-content/2017/02/AzureVM.png

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 
.RELEASENOTES

#>

<# 

.DESCRIPTION 
 A sample report for Azure VMs.  This is more to demostrate ReportHTML functionality.

#> 

#Requires –Modules AzureRM
#Requires –Modules ReportHTML
#Requires -Modules ReportHTMLHelpers


param
(
    $LeftLogo ='https://azurefieldnotesblog.blob.core.windows.net/wp-content/2017/02/YourLogoHere.png',
    $RightLogo ='https://azurefieldnotesblog.blob.core.windows.net/wp-content/2017/02/ReportHTML.png', 
    $reportPath,
    $ReportName='AzureVM',
    [switch]$UseExistingData
)

Test-AzureRmAccountTokenExpiry

if ($UseExistingData) 
{
    Write-Warning "Reusing the data, helpful when developing the report"
} 
else 
{
	$VMs = get-azurermvm 
}

$AzurePortal = "https://portal.azure.com/#resource"
$VMBreakdowns = @()
foreach ($vm in $vms) {
	$VMBreakdown = '' | select ResourceGroup, ID, VMName, OSType, URL, Size, location, StorageAccount
	$VMBreakdown.ResourceGroup = $vm.ResourceGroupName
	$VMBreakdown.ID = $vm.Id
	$VMBreakdown.VMName = $vm.Name
	$VMBreakdown.URL =  ('URL01' + $AzurePortal + $vm.Id + 'URL02' + $vm.Name + 'URL03')
	$VMBreakdown.location = $vm.location 
	$VMBreakdown.Size = $vm.HardwareProfile.VmSize
	#$VMBreakdown.OSType = $vm.OSProfile.WindowsConfiguration 
	$VMBreakdown.StorageAccount = ($vm.StorageProfile.OsDisk.Vhd.Uri.Split('.')[0]).split('//')[2]
	$VMBreakdowns += $VMBreakdown
}

$VMSize = $VMBreakdowns | group size
$VMLocation = $VMBreakdowns | group location
$VMResourceGroup = $VMBreakdowns | group ResourceGroup
$VMStorage = $VMBreakdowns | group StorageAccount

$rpt = @()
$rpt += Get-HtmlOpenpage -TitleText "Azure VM Sizing" -LeftLogoString $LeftLogo -RightLogoString $RightLogo

	$rpt += Get-HtmlContentOpen -HeaderText "Azure VM Report"
		$rpt += Get-HTMLColumn1of2
			$PieObject = Get-HTMLPieChartobject -charttype doughnut
			$PieObject.ChartStyle.ColorSchemeName= 'ColorScheme1'
			$PieObject.Title = 'VMs by Location'
			$PieObject.Size.Width = 400;$PieObject.Size.Height= 400
			$rpt += Get-HTMLPieChart -DataSet $VMLocation -chartobject $PieObject
			$rpt += get-htmlcontenttable (Set-TableRowColor($VMLocation | select Name, count) -Alternating)
		$rpt += Get-HTMLColumnClose
		$rpt += Get-HTMLColumn2of2
			$VMSizeBarObject = Get-HTMLBarChartobject
			$VMSizeBarObject.Title = 'VMs by Size'
			$VMSizeBarObject.Size.Width = 400;$VMSizeBarObject.Size.Height= 400
			$rpt += Get-HTMLBarChart -DataSet $VMSize -chartobject $VMSizeBarObject 
			$rpt += get-htmlcontenttable (Set-TableRowColor ($VMSize | select Name, count) -Alternating)
		$rpt += Get-HTMLColumnClose

		$rpt += Get-HTMLColumn1of2
			$OSPieObject = Get-HTMLPieChartobject 
			$OSPieObject.ChartStyle.ColorSchemeName= 'ColorScheme2'
			$OSPieObject.Title = "VMs by Storage Account Type"
			$OSPieObject.Size.Width = 400;$OSPieObject.Size.Height= 400
			$rpt += Get-HTMLPieChart -DataSet $VMStorage -chartobject $OSPieObject
			$rpt += get-htmlcontenttable (Set-TableRowColor ($VMStorage | select Name, count) -Alternating)
		$rpt += Get-HTMLColumnClose
		$rpt += Get-HTMLColumn2of2
			$VMRGBarObject = Get-HTMLBarChartobject
			$VMRGBarObject.Title = 'VMs Count by Resource Group'
			$VMRGBarObject.Size.Width = 400;$VMRGBarObject.Size.Height= 400
			$rpt += Get-HTMLBarChart -DataSet $VMResourceGroup -chartobject $VMRGBarObject 
			$rpt += get-htmlcontenttable (Set-TableRowColor($VMResourceGroup | select Name, count) -Alternating)
		$rpt += Get-HTMLColumnClose
	$rpt += Get-HtmlContentClose
	$rpt += Get-HtmlContentOpen -HeaderText "Azure VM Data Set" -IsHidden
		$rpt += get-htmlcontenttable (Set-TableRowColor($VMBreakdowns | select ResourceGroup,	URL ,Size	,location	,StorageAccount) -Alternating) -GroupBy ResourceGroup
	$rpt += Get-HtmlContentClose
$rpt += Get-HtmlClosePage

save-htmlreport -reportcontent $rpt -reportpath $reportPath -ReportName $ReportName -showreport




