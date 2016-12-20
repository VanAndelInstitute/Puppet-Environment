function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [parameter(Mandatory = $true)]
        [ValidateSet("Lowest","Low","Medium","High","Expert")]
        [System.String]
        $Level
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-EventLogLevel" -VerbosePreference $VerbosePreference

    $eventLogLevel = Get-EventLogLevel -Identity "$($env:COMPUTERNAME)\$($Identity)"

    if ($eventLogLevel -ne $null)
    {
        $returnValue = @{
            Identity = $Identity
            Level = $eventLogLevel.EventLevel
        }
    }

    $returnValue
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [parameter(Mandatory = $true)]
        [ValidateSet("Lowest","Low","Medium","High","Expert")]
        [System.String]
        $Level
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Set-EventLogLevel" -VerbosePreference $VerbosePreference

    Set-EventLogLevel -Identity "$($env:COMPUTERNAME)\$($Identity)" -Level $Level
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [parameter(Mandatory = $true)]
        [ValidateSet("Lowest","Low","Medium","High","Expert")]
        [System.String]
        $Level
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-EventLogLevel" -VerbosePreference $VerbosePreference

    $eventLogLevel = Get-EventLogLevel -Identity "$($env:COMPUTERNAME)\$($Identity)"

    if ($eventLogLevel -eq $null)
    {
        Write-Error "Failed to retrieve any objects with specified Identity."

        return $false
    }
    else
    {
        if (!(VerifySetting -Name "Level" -Type "String" -ExpectedValue $Level -ActualValue $eventLogLevel.EventLevel -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }
    }

    return $true
}


Export-ModuleMember -Function *-TargetResource

