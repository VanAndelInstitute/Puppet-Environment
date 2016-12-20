function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("AdminSite","AuthSite","TenantSite","WindowsAuthSite")]
        [System.String]
        $Namespace,

        [parameter(Mandatory = $true)]
        [System.String]
        $FullyQualifiedDomainName,

        [System.UInt16]
        $Port,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $AzurePackAdminCredential,

        [parameter(Mandatory = $true)]
        [System.String]
        $SQLServer,

        [System.String]
        $SQLInstance = "MSSQLSERVER"
    )

    if($SQLInstance -eq "MSSQLSERVER")
    {
        $ConnectionString = "Data Source=$SQLServer;Initial Catalog=Microsoft.MgmtSvc.Store;Integrated Security=True"
    }
    else
    {
        $ConnectionString = "Data Source=$SQLServer\$SQLInstance;Initial Catalog=Microsoft.MgmtSvc.Store;Integrated Security=True"
    }

    $FQDN = Invoke-Command -ComputerName . -Credential $AzurePackAdminCredential -Authentication Credssp {
        $Namespace = $args[0]
        $ConnectionString = $args[1]
        Get-MgmtSvcFQDN -Namespace $Namespace -ConnectionString $ConnectionString
    } -ArgumentList @($Namespace,$ConnectionString)

    $returnValue = @{
        Namespace = $Namespace
        FullyQualifiedDomainName = $FQDN.FullyQualifiedDomainName
        Port = $FQDN.Port
        SQLServer = $SQLServer
        SQLInstance = $SQLInstance
    }

    $returnValue
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("AdminSite","AuthSite","TenantSite","WindowsAuthSite")]
        [System.String]
        $Namespace,

        [parameter(Mandatory = $true)]
        [System.String]
        $FullyQualifiedDomainName,

        [System.UInt16]
        $Port,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $AzurePackAdminCredential,

        [parameter(Mandatory = $true)]
        [System.String]
        $SQLServer,

        [System.String]
        $SQLInstance = "MSSQLSERVER"
    )

    if($Port -eq 0)
    {
        Switch($Namespace)
        {
            "AdminSite"
            {
                $Port = 30091
            }
            "AuthSite"
            {
                $Port = 30071
            }
            "TenantSite"
            {
                $Port = 30081
            }
            "WindowsAuthSite"
            {
                $Port = 30072
            }
        }
    }
    
    if($SQLInstance -eq "MSSQLSERVER")
    {
        $ConnectionString = "Data Source=$SQLServer;Initial Catalog=Microsoft.MgmtSvc.Store;Integrated Security=True"
    }
    else
    {
        $ConnectionString = "Data Source=$SQLServer\$SQLInstance;Initial Catalog=Microsoft.MgmtSvc.Store;Integrated Security=True"
    }

    Invoke-Command -ComputerName . -Credential $AzurePackAdminCredential -Authentication Credssp {
        $Namespace = $args[0]
        $FullyQualifiedDomainName = $args[1]
        $Port = $args[2]
        $ConnectionString = $args[3]
        Set-MgmtSvcFQDN -Namespace $Namespace -FullyQualifiedDomainName $FullyQualifiedDomainName -Port $Port -ConnectionString $ConnectionString
    } -ArgumentList @($Namespace,$FullyQualifiedDomainName,$Port,$ConnectionString)

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
        [ValidateSet("AdminSite","AuthSite","TenantSite","WindowsAuthSite")]
        [System.String]
        $Namespace,

        [parameter(Mandatory = $true)]
        [System.String]
        $FullyQualifiedDomainName,

        [System.UInt16]
        $Port,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $AzurePackAdminCredential,

        [parameter(Mandatory = $true)]
        [System.String]
        $SQLServer,

        [System.String]
        $SQLInstance = "MSSQLSERVER"
    )

    if($Port -eq 0)
    {
        Switch($Namespace)
        {
            "AdminSite"
            {
                $Port = 30091
            }
            "AuthSite"
            {
                $Port = 30071
            }
            "TenantSite"
            {
                $Port = 30081
            }
            "WindowsAuthSite"
            {
                $Port = 30072
            }
        }
    }

    $FQDN = Get-TargetResource @PSBoundParameters
    
    $result = (($FQDN.FullyQualifiedDomainName -eq $FullyQualifiedDomainName) -and ($FQDN.Port -eq $Port))

    $result
}


Export-ModuleMember -Function *-TargetResource
