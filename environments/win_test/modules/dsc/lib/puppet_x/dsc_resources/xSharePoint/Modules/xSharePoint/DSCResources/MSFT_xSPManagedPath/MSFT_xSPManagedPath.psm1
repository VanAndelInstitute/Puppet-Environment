function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]  [System.String]  $WebAppUrl,
        [parameter(Mandatory = $true)]  [System.String]  $RelativeUrl,
        [parameter(Mandatory = $true)]  [System.Boolean] $Explicit,
        [parameter(Mandatory = $true)]  [System.Boolean] $HostHeader,
        [parameter(Mandatory = $false)] [System.Management.Automation.PSCredential] $InstallAccount
    )

    Write-Verbose -Message "Looking up the managed path $RelativeUrl in $WebAppUrl"

    $result = Invoke-xSharePointCommand -Credential $InstallAccount -Arguments $PSBoundParameters -ScriptBlock {
        $params = $args[0]
        

        $getParams = @{
            Identity = $params.RelativeUrl 
        }
        if ($params.HostHeader) {
            $getParams.Add("HostHeader", $true)
        } else {
            $getParams.Add("WebApplication", $params.WebAppUrl)
        }
        $path = Get-SPManagedPath @getParams -ErrorAction SilentlyContinue
        if ($null -eq $path) { return $null }
        
        return @{
            RelativeUrl = $path.Name
            Explicit = ($path.Type -eq "ExplicitInclusion")
            WebAppUrl = $params.WebAppUrl
            HostHeader = $params.HostHeader
            InstallAccount = $params.InstallAccount
        }
    }
    return $result
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]  [System.String]  $WebAppUrl,
        [parameter(Mandatory = $true)]  [System.String]  $RelativeUrl,
        [parameter(Mandatory = $true)]  [System.Boolean] $Explicit,
        [parameter(Mandatory = $true)]  [System.Boolean] $HostHeader,
        [parameter(Mandatory = $false)] [System.Management.Automation.PSCredential] $InstallAccount
    )

    Write-Verbose -Message "Creating the managed path $RelativeUrl in $WebAppUrl"

    $path = Get-TargetResource @PSBoundParameters

    if ($null -eq $path) { 
        Invoke-xSharePointCommand -Credential $InstallAccount -Arguments $PSBoundParameters -ScriptBlock {
            $params = $args[0]

            $newParams = @{}
            if ($params.HostHeader) {
                $newParams.Add("HostHeader", $params.HostHeader)
            }
            else {
                $newParams.Add("WebApplication", $params.WebAppUrl)
            }
            $newParams.Add("RelativeURL", $params.RelativeUrl)
            $newParams.Add("Explicit", $params.Explicit)

            New-SPManagedPath @newParams
        }
    }
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]  [System.String]  $WebAppUrl,
        [parameter(Mandatory = $true)]  [System.String]  $RelativeUrl,
        [parameter(Mandatory = $true)]  [System.Boolean] $Explicit,
        [parameter(Mandatory = $true)]  [System.Boolean] $HostHeader,
        [parameter(Mandatory = $false)] [System.Management.Automation.PSCredential] $InstallAccount
    )

    $CurrentValues = Get-TargetResource @PSBoundParameters
    Write-Verbose -Message "Looking up the managed path $RelativeUrl in $WebAppUrl"
    if ($CurrentValues -eq $null) { return $false }
    return Test-xSharePointSpecificParameters -CurrentValues $CurrentValues -DesiredValues $PSBoundParameters -ValuesToCheck @("WebAppUrl","RelativeUrl","Explicit","HostHeader")
}


Export-ModuleMember -Function *-TargetResource

