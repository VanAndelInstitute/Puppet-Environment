function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Admin","Tenant")]
        [System.String]
        $Target,

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
        $ConnectionString = "Data Source=$SQLServer;Initial Catalog=Microsoft.MgmtSvc.PortalConfigStore;Integrated Security=True";
    }
    else
    {
        $ConnectionString = "Data Source=$SQLServer\$SQLInstance;Initial Catalog=Microsoft.MgmtSvc.PortalConfigStore;Integrated Security=True";
    }

    $FQDN = Invoke-Command -ComputerName . -Credential $AzurePackAdminCredential -Authentication Credssp {
        $Target = $args[0]
        $ConnectionString = $args[1]
        switch($Target)
        {
            "Admin"
            {
                $Namespace = "AdminSite"
            }
            "Tenant"
            {
                $Namespace = "TenantSite"
            }
        }
        ((ConvertFrom-Json (Get-MgmtSvcDatabaseSetting -Namespace $Namespace -Name Authentication.IdentityProvider -ConnectionString $ConnectionString).Value).Endpoint).Split("/")[2]
    } -ArgumentList @($Target,$ConnectionString)

    $returnValue = @{
        Target = $Target
        FullyQualifiedDomainName = $FQDN.Split(":")[0]
        Port = $FQDN.Split(":")[1]
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
        [ValidateSet("Admin","Tenant")]
        [System.String]
        $Target,

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
        Switch($Target)
        {
            "Admin"
            {
                $Port = 30072
            }
            "Tenant"
            {
                $Port = 30071
            }
        }
    }
    
    if($SQLInstance -eq "MSSQLSERVER")
    {
        $PortalConnectionString = "Data Source=$SQLServer;Initial Catalog=Microsoft.MgmtSvc.PortalConfigStore;Integrated Security=True";
        $ManagementConnectionString = "Data Source=$SQLServer;Initial Catalog=Microsoft.MgmtSvc.Store;Integrated Security=True";
    }
    else
    {
        $PortalConnectionString = "Data Source=$SQLServer\$SQLInstance;Initial Catalog=Microsoft.MgmtSvc.PortalConfigStore;Integrated Security=True";
        $ManagementConnectionString = "Data Source=$SQLServer\$SQLInstance;Initial Catalog=Microsoft.MgmtSvc.Store;Integrated Security=True";
    }

    Invoke-Command -ComputerName . -Credential $AzurePackAdminCredential -Authentication Credssp {
        $Target = $args[0]
        $FullyQualifiedDomainName = $args[1]
        $Port = $args[2]
        $PortalConnectionString = $args[3]
        $ManagementConnectionString = $args[4]
        Set-MgmtSvcRelyingPartySettings -Target $Target -MetadataEndpoint "https://$FullyQualifiedDomainName`:$Port/FederationMetadata/2007-06/FederationMetadata.xml" -PortalConnectionString $PortalConnectionString -ManagementConnectionString $ManagementConnectionString -DisableCertificateValidation;
    } -ArgumentList @($Target,$FullyQualifiedDomainName,$Port,$PortalConnectionString,$ManagementConnectionString)

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
        [ValidateSet("Admin","Tenant")]
        [System.String]
        $Target,

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
        Switch($Target)
        {
            "Admin"
            {
                $Port = 30072
            }
            "Tenant"
            {
                $Port = 30071
            }
        }
    }

    $FQDN = Get-TargetResource @PSBoundParameters
    
    $result = (($FQDN.FullyQualifiedDomainName -eq $FullyQualifiedDomainName) -and ($FQDN.Port -eq $Port))

    $result
}


Export-ModuleMember -Function *-TargetResource
