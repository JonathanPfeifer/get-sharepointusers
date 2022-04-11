# Get all SharePoint Users from SharePoint Farm and export them to csv file 

param(
    [string]$SiteUrl,
    [string]$OutFile
)


function Get-SharePointUsers {
    param (
        [string]$_siteurl,
        [string]$_outfile 
    )
    
    Add-PSSnapin -Name "Microsoft.SharePoint.PowerShell" 

    $serviceContext = Get-SPServiceContext -Site $_siteurl 
    $profileManager = New-Object Microsoft.Office.Server.UserProfiles.UserProfileManager($serviceContext)
    $profiles = $profileManager.GetEnumerator() 

    $fields = @(
        "AccountName",
        "WorkEmail",
        "UserName"
    )

    $results = New-Object -TypeName "System.Collection.ArrayList"
    
    foreach ($profile in $profiles) {
        $user = "" | Select-Object $fields
        foreach ( $field in $fields) {
            if ($profile[$field].Property.IsMultivalued) {
                $user.$field = $profile[$field] -join "|"
            }
            else {
                $user.$field = $profile[$field].Value
            }
        }

        $results += $user
    }

    $results | Export-Csv $_outfile -NoTypeInformation
}

Get-SharePointUsers SiteUrl OutFile