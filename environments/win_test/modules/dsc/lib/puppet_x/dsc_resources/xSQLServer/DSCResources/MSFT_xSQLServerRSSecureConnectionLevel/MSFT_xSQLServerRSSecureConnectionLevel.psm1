function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $InstanceName,
        
        [parameter(Mandatory = $true)]
        [System.UInt16]
        $SecureConnectionLevel,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SQLAdminCredential
    )

    if(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\RS" -Name $InstanceName -ErrorAction SilentlyContinue)
    {
        $InstanceKey = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\RS" -Name $InstanceName).$InstanceName
        $SQLVersion = ((Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$InstanceKey\Setup" -Name "Version").Version).Split(".")[0]
        $SecureConnectionLevel = Invoke-Command -ComputerName . -Credential $SQLAdminCredential -ScriptBlock {
            $SQLVersion = $args[0]
            $InstanceName = $args[1]
            $RSConfig = Get-WmiObject -Class MSReportServer_ConfigurationSetting -Namespace "root\Microsoft\SQLServer\ReportServer\RS_$InstanceName\v$SQLVersion\Admin"
            $RSConfig.SecureConnectionLevel
        } -ArgumentList @($SQLVersion,$InstanceName)
    }
    else
    {
        Throw "SQL Reporting Services instance $InstanceName does not exist!"
    }

    $returnValue = @{
        InstanceName = $InstanceName
        SecureConnectionLevel = $SecureConnectionLevel
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
        $InstanceName,
        
        [parameter(Mandatory = $true)]
        [System.UInt16]
        $SecureConnectionLevel,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SQLAdminCredential
    )

    if(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\RS" -Name $InstanceName -ErrorAction SilentlyContinue)
    {
        $InstanceKey = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\RS" -Name $InstanceName).$InstanceName
        $SQLVersion = ((Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$InstanceKey\Setup" -Name "Version").Version).Split(".")[0]
        Invoke-Command -ComputerName . -Credential $SQLAdminCredential -ScriptBlock {
            $SQLVersion = $args[0]
            $InstanceName = $args[1]
            $SecureConnectionLevel = $args[2]
            $RSConfig = Get-WmiObject -Class MSReportServer_ConfigurationSetting -Namespace "root\Microsoft\SQLServer\ReportServer\RS_$InstanceName\v$SQLVersion\Admin"
            $RSConfig.SetSecureConnectionLevel($SecureConnectionLevel)
        } -ArgumentList @($SQLVersion,$InstanceName,$SecureConnectionLevel)
    }

    if(!(Test-TargetResource @PSBoundParameters))
    {
        throw "Set-TargetResouce failed"
    }
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $InstanceName,
        
        [parameter(Mandatory = $true)]
        [System.UInt16]
        $SecureConnectionLevel,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SQLAdminCredential
    )

    $result = ((Get-TargetResource @PSBoundParameters).SecureConnectionLevel -eq $SecureConnectionLevel)

    $result
}


Export-ModuleMember -Function *-TargetResource
