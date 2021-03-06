<#PSScriptInfo

.VERSION 1.0.0.0

.GUID 2b32a6b1-3ba3-4b6c-a4dd-2c3f09f2f835

.AUTHOR Matthew Quickenden

.COMPANYNAME Avanade / ACE

.COPYRIGHT 

.TAGS Report HTML Azure RBAC

.LICENSEURI https://github.com/azurefieldnotes/Reports

.PROJECTURI https://github.com/azurefieldnotes/Reports

.ICONURI 

.EXTERNALMODULEDEPENDENCIES AzureRM

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 
.RELEASENOTES


#>

<# 

.DESCRIPTION 
 A report to show Meter Rates from Azure.  This is a prototype.  
#> 

#Requires –Modules AzureRM
#Requires –Modules ReportHTML
#Requires -Modules ReportHTMLHelpers


[CmdletBinding(DefaultParameterSetName='ReportParameters')]
param 
(
    [Parameter(Mandatory=$false,ParameterSetName='ReportParameters')]
    [string]
    $LeftLogo ='https://azurefieldnotesblog.blob.core.windows.net/wp-content/2017/02/YourLogoHere.png',
    [Parameter(Mandatory=$false,ParameterSetName='ReportParameters')]
    [string]
    $RightLogo ='https://azurefieldnotesblog.blob.core.windows.net/wp-content/2017/02/ReportHTML.png', 
    [Parameter(Mandatory=$false,ParameterSetName='ReportParameters')]
    [string]
    $reportPath,
    [Parameter(Mandatory=$false,ParameterSetName='ReportParameters')]
    [string]
    $ReportName='Azure Meter Rates',
    [Parameter(Mandatory=$false,ParameterSetName='ReportParameters')]
    [Parameter(Mandatory=$false,ParameterSetName='ReportParametersObject')]
    [switch]
    $UseExistingData,
    [Parameter(Mandatory=$false,ParameterSetName='ReportParametersObject')]
    [PSObject]
    $ReportParameterObject
)

remove-module reporthtml
Remove-Module ReportHTMLHelpers
cls
import-module C:\Users\matt.quickenden\Documents\GitHub\ReportHTML\ReportHTML\ReportHTML.psd1
import-module C:\Users\matt.quickenden\Documents\GitHub\ReportHTMLHelpers\ReportHTMLHelpers.psd1
Get-Module reporthtml
Get-Module reporthtmlhelpers
$ChartObject= Get-HTMLBarChartObject
#Test-AzureRmAccountTokenExpiry

$id = 1
if ($UseExistingData) 
{
    Write-Warning "Reusing the data, helpful when developing the report"
} 
else
{
	#,@{n='EffectiveDate1';E={[datetime]$_.EffectiveDate}}
	$AzureRates = $AzureData.RateCards
	$Data = $AzureRates | select MeterCategory,Unit, EffectiveDate ,MeterName,@{n='MeterRates';E={$_.MeterRates.replace('0=','')}}  , MeterRegion,MeterSubCategory | ? {$_.MeterRegion -ne ''}
	$MeterCategories = ($Data | group MeterCategory).name
}


$rpt   = @()
$rpt += Get-HTMLOpenPage -LeftLogoString $LeftLogo  -RightLogoString $RightLogo -TitleText $ReportName
$rpt += Get-HTMLTabheader $MeterCategories 
$mc = 1
foreach ($MeterCategory in $MeterCategories ) {

	Write-Progress -Id $id -Activity "Building Azure Meter Rates Report" -Status "Collecting Azure Meter Rates for $MeterCategory" -PercentComplete ($mc/ $MeterCategories.Count*100 ) 
#$MeterCategory  = 'Azure App Service'
	$CategoryData = $Data | where {$_.MeterCategory    -eq $MeterCategory} 
	$Grouped = $CategoryData | group MeterSubCategory, metername  | sort name | select -First 3
	
	
	
	
	
	$rpt += Get-HTMLTabContentOpen -TabName $MeterCategory -TabHeading " "
	
	$bar = Get-HTMLBarChartObject -ColorScheme Random
	$bar.Title = "Summary"
	$bar.DataDefinition.DataNameColumnName = 'MeterRegion'
	$bar.DataDefinition.DataValueColumnName = 'MeterRates'
	$bar.DataDefinition.DataSetName = 
	$bar.Size.Height =400
	$bar.Size.width =800
	$bar.DataDefinition.AxisYTitle = $CategoryData[0].metername $CategoryData[0].UNIT
	$bar.ChartStyle.legendPosition ='none'

	$rpt += Get-HTMLBarChart -ChartObject $bar -DataSet ($CategoryData| Sort meterrates) 
	
	
	$rpt += Get-HTMLContentOpen -HeaderText 'Anchor Links' -IsHidden
	$rpt += $Grouped | % {(Get-HTMLAnchorLink -AnchorName $_.name -AnchorText $_.name)+ ' | ' } 
	$rpt += Get-HTMLContentClose
	$G=1
	foreach ($Group in $Grouped )
	{	
		$Groupname = $Group.Name
		Write-Progress -Id ($id+1) -Activity "Processing Grouped Data" -Status "working with $Groupname" -PercentComplete ($g/ $Grouped.Count*100 ) -ParentId ($id)
		$bar = Get-HTMLBarChartObject -ColorScheme Random
		$bar.Title
		$bar.DataDefinition.DataNameColumnName = 'MeterRegion'
		$bar.DataDefinition.DataValueColumnName = 'MeterRates'
		$bar.DataDefinition.DataSetName = $Group[0].group[0].metername
		$bar.Size.Height =400
		$bar.Size.width =800
		$bar.DataDefinition.AxisXTitle = "Meter Region"
		$bar.DataDefinition.AxisYTitle = $Group[0].group[0].Unit
		$bar.ChartStyle.legendPosition ='Bottom'

		$rpt += Get-HTMLContentOpen -IsHidden -HeaderText $Group.Name -Anchor $Group.Name 
		$rpt += Get-HTMLBarChart -ChartObject $bar -DataSet ($Group.Group | Sort meterrates) 
		$rpt += Get-HTMLContentTable ($Group.Group | select EffectiveDate,MeterCategory,MeterSubCategory,MeterName,MeterRegion,Unit, MeterRates  | Sort EffectiveDate )
		$rpt += Get-HTMLContentclose
		$G++
	}
	$rpt  += Get-HTMLTabContentclose
	$mc++
}

$rpt += Get-HTMLClosePage
Save-HTMLReport -ReportContent $rpt -ReportPath $ReportPath -ReportName $ReportName.Replace(' ','') -ShowReport 
