function Sanitize-ProfileName
{
    param(
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            Position = 0
        )]
        [String]
        $ProfileName
    )


    $ProfileName -replace "'", "\'"
}


function Validate-ProfileNameExists
{
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [String]
        $ProfileName
    )


    $SanitizedName = Sanitize-ProfileName $ProfileName
    [bool](Get-CimInstance -Name root\cimv2\power -Class win32_PowerPlan -Filter "ElementName = '${SanitizedName}'")
}


function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param
    (
        [parameter(
            Mandatory
        )]
        [System.String]
        $Name
    )


    $Instance = Get-CimInstance -Name root\cimv2\power -Class win32_PowerPlan -Filter 'IsActive = True'
    @{
        Name = $Name
        ProfileName = $Instance.ElementName
    }
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(
            Mandatory
        )]
        [String]
        $Name,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
            $_ | Validate-ProfileNameExists
        } )]
        [String]
        $ProfileName
    )


    $SanitizedName = Sanitize-ProfileName $ProfileName
    $Instance = Get-CimInstance -Name root\cimv2\power -Class win32_PowerPlan -Filter "ElementName = '${SanitizedName}'"
    Invoke-CimMethod -InputObject $Instance -MethodName Activate
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(
            Mandatory
        )]
        [String]
        $Name,

        [String]
        $ProfileName
    )


    $SanitizedName = Sanitize-ProfileName $ProfileName
    $Instance = Get-CimInstance -Name root\cimv2\power -Class win32_PowerPlan -Filter "ElementName = '${SanitizedName}'"
    $Instance.IsActive -eq $true
}


Export-ModuleMember -Function *-TargetResource

