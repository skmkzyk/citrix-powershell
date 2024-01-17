$modulePath = Join-Path $PSScriptRoot "AccessTokenManager.psm1"
Import-Module $modulePath

$script:CITRIX_BASE_URL = "https://api.cloud.com/cvad/manage"

####################################################################################################
# public functions
####################################################################################################

function Get-CitrixDeliveryGroups {
    $response = Invoke-CitrixRestMethod -PartUrl "DeliveryGroups"

    return $response
}

function Get-CitrixDeliveryGroup {
    param (
        [Parameter(Mandatory = $true)]
        [string]$DeliveryGroupName
    )

    $response = Invoke-CitrixRestMethod -PartUrl "DeliveryGroups/$DeliveryGroupName"

    return $response
}

function Get-CitrixDeliveryGroupMachines {
    param (
        [Parameter(Mandatory = $true)]
        [string]$DeliveryGroupName,

        [Parameter(Mandatory = $false)]
        [string]$ContinuationToken
    )

    $part_url = "DeliveryGroups/$DeliveryGroupName/Machines"
    if ($ContinuationToken) {
        $part_url += "?ContinuationToken=$ContinuationToken"
    }
    $response = Invoke-CitrixRestMethod -PartUrl $part_url

    return $response
}

function Add-CitrixDeliveryGroupMachine {
    param (
        [Parameter(Mandatory = $true)]
        [string]$DeliveryGroupName,

        [Parameter(Mandatory = $true)]
        [string]$MachineName,

        [Parameter(Mandatory = $true)]
        [string]$MachineCatalogName
    )

    $body = @{
        "MachineCatalog"        = $MachineCatalogName
        "AssignMachinesToUsers" = @( @{
                "Machine" = $MachineName
            } )
    } | ConvertTo-Json

    $response = Invoke-CitrixRestMethod -PartUrl "DeliveryGroups/$DeliveryGroupName/Machines" -Method "Post" -Body $body

    return $response
}

function Add-CitrixDeliveryGroupSimpleAccessPolicyIncludedUser {
    param (
        [Parameter(Mandatory = $true)]
        [string]$DeliveryGroupName,

        [Parameter(Mandatory = $true)]
        [string]$UserName
    )

    $response = Get-CitrixDeliveryGroup -DeliveryGroupName $DeliveryGroupName
    $currentIncludedUsers = $response.SimpleAccessPolicy.IncludedUsers | Select-Object -ExpandProperty SamName

    $body = @{
        "SimpleAccessPolicy" = @{
            "IncludedUsers" = $currentIncludedUsers + @($UserName)
        }
    } | ConvertTo-Json

    $response = Invoke-CitrixRestMethod -PartUrl "DeliveryGroups/$DeliveryGroupName" -Method "Patch" -Body $body

    return $response
}

function Remove-CitrixDeliveryGroupMachine {
    param (
        [Parameter(Mandatory = $true)]
        [string]$DeliveryGroupName,

        [Parameter(Mandatory = $true)]
        [string]$MachineName
    )

    $response = Invoke-CitrixRestMethod -PartUrl "DeliveryGroups/$DeliveryGroupName/Machines/$MachineName" -Method "Delete"

    return $response
}

function Get-CitrixHypervisors {
    $response = Invoke-CitrixRestMethod -PartUrl "Hypervisors"

    return $response
}

function Get-CitrixHypervisorMachineCatalogs {
    param (
        [Parameter(Mandatory = $true)]
        [string]$HypervisorName
    )

    $response = Invoke-CitrixRestMethod -PartUrl "Hypervisors/$HypervisorName/MachineCatalogs"

    return $response
}

function Get-CitrixMachine {
    param (
        [Parameter(Mandatory = $true)]
        [string]$MachineName
    )

    $response = Invoke-CitrixRestMethod -PartUrl "Machines/$MachineName"

    return $response
}

function Update-CitrixMachineCatalogMachine {
    param (
        [Parameter(Mandatory = $true)]
        [string]$MachineName,

        [Parameter(Mandatory = $true)]
        [string]$AssignedUsers,

        [Parameter(Mandatory = $true)]
        [string]$HostedMachineId,

        [Parameter(Mandatory = $true)]
        [string]$HypervisorConnection,

        [Parameter(Mandatory = $true)]
        [string]$PublishedName
    )

    $body = @{
        "AssignedUsers"        = @($AssignedUsers)
        "HostedMachineId"      = $HostedMachineId
        "HypervisorConnection" = $HypervisorConnection
        "PublishedName"        = $PublishedName
    } | ConvertTo-Json

    $response = Invoke-CitrixRestMethod -PartUrl "Machines/$MachineName" -Method "Patch" -Body $body

    return $response
}

function Get-CitrixMachineSession {
    param (
        [Parameter(Mandatory = $true)]
        [string]$MachineName
    )

    $response = Invoke-CitrixRestMethod -PartUrl "Machines/$MachineName/Sessions"

    return $response
}

function Get-CitrixMachineCatalogs {
    $response = Invoke-CitrixRestMethod -PartUrl "MachineCatalogs"

    return $response
}

function Get-CitrixMachineCatalog {
    param (
        [Parameter(Mandatory = $true)]
        [string]$MachineCatalogName
    )

    $response = Invoke-CitrixRestMethod -PartUrl "MachineCatalogs/$MachineCatalogName"

    return $response
}

function Get-CitrixMachineCatalogMachines {
    param (
        [Parameter(Mandatory = $true)]
        [string]$MachineCatalogName,

        [Parameter(Mandatory = $false)]
        [string]$ContinuationToken
    )

    $part_url = "MachineCatalogs/$MachineCatalogName/Machines"
    if ($ContinuationToken) {
        $part_url += "?ContinuationToken=$ContinuationToken"
    }
    $response = Invoke-CitrixRestMethod -PartUrl $part_url

    return $response
}

function Add-CitrixMachineCatalogMachine {
    param (
        [Parameter(Mandatory = $true)]
        [string]$MachineCatalogName,

        [Parameter(Mandatory = $true)]
        [string]$MachineName,

        [Parameter(Mandatory = $true)]
        [string]$HypervisorConnection,

        [Parameter(Mandatory = $true)]
        [string]$HostedMachineId
    )

    $body = @{
        "MachineName"          = $MachineName
        "HypervisorConnection" = $HypervisorConnection
        "HostedMachineId"      = $HostedMachineId
    } | ConvertTo-Json

    $response = Invoke-CitrixRestMethod -PartUrl "MachineCatalogs/$MachineCatalogName/Machines" -Method "Post" -Body $body

    return $response
}

function Remove-CitrixMachineCatalogMachine {
    param (
        [Parameter(Mandatory = $true)]
        [string]$MachineCatalogName,

        [Parameter(Mandatory = $true)]
        [string]$MachineName
    )

    $response = Invoke-CitrixRestMethod -PartUrl "MachineCatalogs/$MachineCatalogName/Machines/$MachineName" -Method "Delete"

    return $response
}

####################################################################################################
# private functions
####################################################################################################

# private function to get instance id
function Get-CitrixInstanceId {
    # return error if customer id is not set
    if (-not $Env:CUSTOMER_ID) {
        throw "CUSTOMER_ID environment variable must be set"
    }

    $AccessToken = Get-CitrixAccessToken

    $url = "$script:CITRIX_BASE_URL/me"

    $headers = @{
        "Accept"            = "application/json"
        "Content-Type"      = "application/json; charset=utf-8"
        "Authorization"     = "CwsAuth Bearer=$AccessToken"
        "Citrix-CustomerId" = $Env:CUSTOMER_ID
    }

    $response = Invoke-RestMethod -Uri $url -Headers $headers

    return $response.Customers.Sites.Id
}

# private function to invoke Citrix REST API
function Invoke-CitrixRestMethod {
    param (
        [Parameter(Mandatory = $true)]
        [string]$PartUrl,

        [Parameter(Mandatory = $false)]
        [string]$Method = "Get",

        [Parameter(Mandatory = $false)]
        [string]$Body
    )

    $AccessToken = Get-CitrixAccessToken

    # get instance id if not set
    if (-not $script:INSTANCE_ID) {
        $script:INSTANCE_ID = Get-CitrixInstanceId
    }

    $headers = @{
        "Accept"            = "application/json"
        "Content-Type"      = "application/json; charset=utf-8"
        "Authorization"     = "CwsAuth Bearer=$AccessToken"
        "Citrix-CustomerId" = $Env:CUSTOMER_ID
        "Citrix-InstanceId" = $script:INSTANCE_ID
    }

    $url = "$script:CITRIX_BASE_URL/$PartUrl"
    $response = Invoke-RestMethod -Uri $Url -Method $Method -Headers $Headers -Body $Body

    return $response
}

$functionsToExport = @(
    'Get-CitrixDeliveryGroups',
    'Get-CitrixDeliveryGroup',
    'Get-CitrixDeliveryGroupMachines',
    'Add-CitrixDeliveryGroupMachine',
    'Add-CitrixDeliveryGroupSimpleAccessPolicyIncludedUser',
    'Remove-CitrixDeliveryGroupMachine',
    'Get-CitrixHypervisors',
    'Get-CitrixHypervisorMachineCatalogs',
    'Get-CitrixMachine',
    'Update-CitrixMachineCatalogMachine',
    'Get-CitrixMachineSession',
    'Get-CitrixMachineCatalogs',
    'Get-CitrixMachineCatalog',
    'Get-CitrixMachineCatalogMachines',
    'Add-CitrixMachineCatalogMachine',
    'Remove-CitrixMachineCatalogMachine'
)

Export-ModuleMember -Function $functionsToExport
