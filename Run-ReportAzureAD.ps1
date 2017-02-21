<#PSScriptInfo

.VERSION 1.0.0.0

.GUID 4258516b-09a1-4912-b317-86178c0afcb1

.AUTHOR Matthew Quickenden

.COMPANYNAME Avanade / ACE

.COPYRIGHT 

.TAGS Report HTML Azure AD

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
#Requires -Modules Avanade.AzureAD.Graph
#Requires -Modules Avanade.ArmTools
#Requires -Modules Avanade.AzureAD



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
    $ReportName='Azure Active Directory Report',
    [Parameter(Mandatory=$false,ParameterSetName='ReportParameters')]
    [Parameter(Mandatory=$false,ParameterSetName='ReportParametersObject')]
    [switch]
    $UseExistingData=$true,
    [Parameter(Mandatory=$false,ParameterSetName='ReportParametersObject')]
    [PSObject]
    $ReportParameterObject
)


#$AzureDataScript = join-path $PSScriptRoot Get-AzureDataSet.ps1
if (!($UseExistingData))
{		
	$AzureData = . $AzureDataScript -GraphTenants 'ci.avahc.com' -TenantEvents -OAuthPermissionGrants
} 
else
{
	Write-Warning "Using Existing Data"
}

$PortalLink = 'https://portal.azure.com/#resource'
$colourSchemes = Get-HTMLColorSchemes 
$tabHeaders = @('Advisor Recommendations','Event Logs','Policy Definitions','RBAC','Resource Locks')

$rpt = @()
$rpt += Get-HTMLOpenPage -LeftLogoString $LeftLogo  -RightLogoString $RightLogo -TitleText $ReportName
$rpt += Get-HTMLTabheader $tabHeaders

#region Resource Locks
$tab = 'Resource Locks'
$rpt += Get-HTMLTabContentOpen -TabName  $tab  -TabHeading $tab 
	$rpt += Get-HTMLContentOpen -HeaderText 'Resource Lock Records'
		$rpt += Get-HTMLContentTable ($AzureData.ResourceLocks | select @{n='Resource';e={("URL01NEW" + $PortalLink + $_.Id + "URL02Goto ResourceURL03")}},Name,Level,Notes)
	$rpt += Get-HTMLContentClose	
$rpt += Get-HTMLTabContentclose
#Endregion

#region AdvisorRecommendations

$ImpactGroup = $AzureData.AdvisorRecommendations | Group Impact   
$ImpactPie = Get-HTMLPieChartObject -ColorScheme ColorScheme3
$CategoryGroup = $AzureData.AdvisorRecommendations | Group Category
$CategoryPie = Get-HTMLPieChartObject -ColorScheme Generated6

$tab = 'Advisor Recommendations'
$rpt += Get-HTMLTabContentOpen -TabName  $tab  -TabHeading $tab 
	$rpt += Get-HTMLContentOpen -HeaderText 'Advisor Recommendations'
		$rpt += Get-HTMLColumn1of2
			$rpt += Get-HTMLPieChart -ChartObject $ImpactPie -DataSet $ImpactGroup
		$rpt += Get-HTMLColumnclose
		$rpt += Get-HTMLColumn2of2
			$rpt += Get-HTMLPieChart -ChartObject $CategoryPie -DataSet $CategoryGroup
		$rpt += Get-HTMLColumnclose
		$rpt += Get-HTMLContentTable ($AzureData.AdvisorRecommendations | select Category,Impact,ResourceType,ResourceName,Risk,Problem,`
		@{n='Resource';e={("URL01NEW" + $PortalLink + $_.ResourceURI + "URL02Goto ResourceURL03")}}		) -GroupBy Category
	$rpt += Get-HTMLContentClose	
$rpt += Get-HTMLTabContentclose
#endRegion
#
##Region Rate Cards
#$tab = $tabHeaders[2]
#$rpt += Get-HTMLTabContentOpen -TabName  $tab  -TabHeading $tab 
#
#$MeterCategories = ($AzureData.RateCards | group MeterCategory).name
#
#$rpt += Get-HTMLTabheader $MeterCategories 
#$mc = 1
#foreach ($MeterCategory in $MeterCategories ) {
#
#	Write-Progress -Id $id -Activity "Building Azure Meter Rates Report" -Status "Collecting Azure Meter Rates for $MeterCategory" -PercentComplete ($mc/ $MeterCategories.Count*100 ) 
##$MeterCategory  = 'Azure App Service'
#	$CategoryData = $Data | where {$_.MeterCategory    -eq $MeterCategory} 
#	$Grouped = $CategoryData | group MeterSubCategory, metername  | sort name | select -First 5
#	
#	
#	
#	
#	
#	$rpt += Get-HTMLTabContentOpen -TabName $MeterCategory -TabHeading " "
#	
#	$bar = Get-HTMLBarChartObject -ColorScheme Random
#	$bar.Title = "Summary"
#	$bar.DataDefinition.DataNameColumnName = 'MeterRegion'
#	$bar.DataDefinition.DataValueColumnName = 'MeterRates'
#	$bar.DataDefinition.DataSetName = 
#	$bar.Size.Height =400
#	$bar.Size.width =800
#	$bar.DataDefinition.AxisXTitle = "Meter Region"
#	$bar.DataDefinition.AxisXTitle = "Cost per Compute Hour"
#	$bar.ChartStyle.legendPosition ='none'
#
#	$rpt += Get-HTMLBarChart -ChartObject $bar -DataSet ($CategoryData| Sort meterrates) 
#	
#	
#	$rpt += Get-HTMLContentOpen -HeaderText 'Anchor Links' -IsHidden
#	$rpt += $Grouped | % {(Get-HTMLAnchorLink -AnchorName $_.name -AnchorText $_.name)+ ' | ' } 
#	$rpt += Get-HTMLContentClose
#	$G=1
#	foreach ($Group in $Grouped )
#	{	
#		$Groupname = $Group.Name
#		Write-Progress -Id ($id+1) -Activity "Processing Grouped Data" -Status "working with $Groupname" -PercentComplete ($g/ $Grouped.Count*100 ) -ParentId ($id)
#		$bar = Get-HTMLBarChartObject -ColorScheme Random
#		$bar.Title
#		$bar.DataDefinition.DataNameColumnName = 'MeterRegion'
#		$bar.DataDefinition.DataValueColumnName = 'MeterRates'
#		$bar.DataDefinition.DataSetName = 
#		$bar.Size.Height =400
#		$bar.Size.width =800
#		$bar.DataDefinition.AxisXTitle = "Meter Region"
#		$bar.DataDefinition.AxisXTitle = "Cost per Compute Hour"
#		$bar.ChartStyle.legendPosition ='none'
#
#		$rpt += Get-HTMLContentOpen -IsHidden -HeaderText $Group.Name -Anchor $Group.Name 
#		$rpt += Get-HTMLBarChart -ChartObject $bar -DataSet ($Group.Group | Sort meterrates) 
#		$rpt += Get-HTMLContentTable ($Group.Group | select EffectiveDate,MeterCategory,MeterSubCategory,MeterName,MeterRegion,Unit, MeterRates  | Sort EffectiveDate )
#		$rpt += Get-HTMLContentclose
#		$G++
#	}
#	$rpt  += Get-HTMLTabContentclose
#	$mc++
#}
#
#$rpt  += Get-HTMLTabContentclose
##endregion
#


#region Event Logs
$EventsLog = $AzureData.EventLogs
$LevelGroup = $EventsLog | Group Level   
$LevelPie = Get-HTMLPieChartObject -ColorScheme Random
$LevelPie.Size.Height =300
$EventSourceGroup = $EventsLog | Group EventSource                  
$EventSourcePie = Get-HTMLPieChartObject -ColorScheme Generated6
$EventSourcePie.Size.Height =300
$RGGroup = $EventsLog | Group ResourceGroupName         
$RGPie = Get-HTMLPieChartObject -ColorScheme ColorScheme4
$RGPie.Size.Height =300
$ChannelsGroup = $EventsLog | Group Channels                                 
$ChannelsPie = Get-HTMLPieChartObject -ColorScheme Generated7
$ChannelsPie.Size.Height =300



$tab = 'Event Logs'
$rpt += Get-HTMLTabContentOpen -TabName  $tab  -TabHeading $tab 
	$rpt += Get-HTMLContentOpen -HeaderText 'Event Logs'
		
		$rpt += Get-HTMLColumn1of2
			$rpt += Get-HTMLPieChart -ChartObject $LevelPie -DataSet $LevelGroup
		$rpt += Get-HTMLColumnclose
		$rpt += Get-HTMLColumn2of2
			$rpt += Get-HTMLPieChart -ChartObject $EventSourcePie -DataSet $EventSourceGroup
		$rpt += Get-HTMLColumnclose
		
		$rpt += Get-HTMLColumn1of2
			$rpt += Get-HTMLPieChart -ChartObject $RGPie -DataSet $RGGroup
		$rpt += Get-HTMLColumnclose
		$rpt += Get-HTMLColumn2of2
			$rpt += Get-HTMLPieChart -ChartObject $ChannelsPie -DataSet $ChannelsGroup
		$rpt += Get-HTMLColumnclose
		
		$rpt += Get-HTMLContentOpen -HeaderText 'Events by Resource Group' -IsHidden
			$rpt += Get-HTMLContentTable ($EventsLog | select  ResourceGroupName,`
				@{n='Resource';e={("URL01NEW" + $PortalLink + $_.ResourceURI + "URL02Goto ResourceURL03")}}, `
				@{n='Event';e={("URL01NEW" + $PortalLink + $_.ID + "URL02Goto EventURL03")}}, `
				ResourceProviderName,OperationName) -GroupBy ResourceGroupName      
		$rpt += Get-HTMLContentClose	
		
		$rpt += Get-HTMLContentOpen -HeaderText 'Events by ResourceProviderName' -IsHidden
			$rpt += Get-HTMLContentTable ($EventsLog | select  ResourceProviderName,`
				@{n='Resource';e={("URL01NEW" + $PortalLink + $_.ResourceURI + "URL02Goto ResourceURL03")}},`
				@{n='Event';e={("URL01NEW" + $PortalLink + $_.ID + "URL02Goto EventURL03")}}, `
				EventSource   ,ResourceGroupName, OperationName) -GroupBy ResourceProviderName   
		$rpt += Get-HTMLContentClose	
		
	$rpt += Get-HTMLContentClose	
$rpt += Get-HTMLTabContentclose
#Endregion

#region Policy Definitions
$PolicyDefinitions = $AzureData.PolicyDefinitions
$PolicyAssignments = $AzureData.PolicyAssignments

$tab = 'Policy Definitions'
$rpt += Get-HTMLTabContentOpen -TabName  $tab  -TabHeading $tab 
	$rpt += Get-HTMLContentOpen -HeaderText 'Policy Definitions' -BackgroundShade 2
		$rpt += Get-HTMLContentOpen -HeaderText 'Policy Definitions' -IsHidden
			$rpt += Get-HTMLContentTable ($PolicyDefinitions | select  DisplayName,Description ,PolicyType )
		$rpt += Get-HTMLContentClose	
		$rpt += Get-HTMLContentOpen -HeaderText 'Policy Assignments' -IsHidden
			$rpt += Get-HTMLContentTable ($PolicyAssignments | select  Name,Scope)
		$rpt += Get-HTMLContentClose	
	$rpt += Get-HTMLContentClose	
$rpt += Get-HTMLTabContentclose
#Endregion

#region RBAC
$roles= $AzureData.roles      
$groups = $AzureData.Groups
$users = $AzureData.Users
$RoleTemplates = $AzureData.RoleTemplates          
$RoleAssignments = $AzureData.RoleAssignments
$tab = 'RBAC'
$rpt += Get-HTMLTabContentOpen -TabName  $tab  -TabHeading $tab 
	$rpt += Get-HTMLContentOpen -HeaderText 'RBAC' -BackgroundShade 2
		$rpt += Get-HTMLContentOpen -HeaderText 'Groups' -IsHidden
			$rpt += Get-HTMLContentTable ($groups | select  DisplayName,ObjectType ,DirSyncEnabled,LastDirSyncTime              ) 
		$rpt += Get-HTMLContentClose
		$rpt += Get-HTMLContentOpen -HeaderText 'Users' -IsHidden
			$rpt += Get-HTMLContentTable ($users | select  DisplayName,AccountEnabled,ForceChangePasswordNextLogin ,DirSyncEnabled,LastDirSyncTime,UserPrincipalName,UserType) 
		$rpt += Get-HTMLContentClose
		$rpt += Get-HTMLContentOpen -HeaderText 'Roles' -IsHidden
			$rpt += Get-HTMLContentTable ($roles | select  DisplayName,Description ,IsSystem,	ObjectType,RoleDisabled) 
		$rpt += Get-HTMLContentClose	
		$rpt += Get-HTMLContentOpen -HeaderText 'Role Templates' -IsHidden
			$rpt += Get-HTMLContentTable ($RoleTemplates | select  DisplayName,Description ,IsSystem,	ObjectType,RoleDisabled) 
		$rpt += Get-HTMLContentClose	
		$rpt += Get-HTMLContentOpen -HeaderText 'Role Assignments' -IsHidden
			$rpt += Get-HTMLContentTable ($RoleAssignments | select PrincipalId ,RoleDefinitionId , Scope  ) 
		$rpt += Get-HTMLContentClose
	$rpt += Get-HTMLContentClose	
$rpt += Get-HTMLTabContentclose
#Endregion


$rpt += Get-HTMLClosePage
Save-HTMLReport -ReportContent $rpt -ReportPath $ReportPath -ReportName $ReportName.Replace(' ','') -ShowReport 

