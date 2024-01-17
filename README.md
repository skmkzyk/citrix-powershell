# citrix-powershell
unofficial PowerShell modules for Citrix Cloud DaaS.
It works for Azure connected DaaS only.

For Japanese, see [README-ja.md](README-ja.md).

# How to use

## Create an API client

To use the cmdlets, you need to create an API client in Citrix Cloud.

https://developer-docs.citrix.com/en-us/citrix-cloud/citrix-cloud-api-overview/get-started-with-citrix-cloud-apis.html

## Place the module files in the module path

Copy `Citrix` folder to `$HOME\Documents\PowerShell\Modules` folder.
That might be `C:\Users\xxxxxxxx\OneDrive - xxxxxxxx\Documents\PowerShell\Modules` folder if you're using OneDrive for Business.

I don't intend to publish this module to PowerShell Gallery, because it's unofficial.

## Define environment variables

```powershell
$Env:CUSTOMER_ID = "xxxxxxxx"
$Env:CLIENT_ID = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
$Env:CLIENT_SECRET = "xxxxxxxxxxxxxxxxxxxxxxxx"
```

## Run cmdlets

Then, you can run cmdlets.
The access token for Citrix Cloud API is implicitly acquired by the cmdlets, so you don't need to care about it.
Not all the cmdlets are implemented, and documented here.
To list all the cmdlets, run `Get-Command -Module Citrix`.

### cmdlets for machines

- Get machine info.

    ```powershell
    $MachineName = "Ops2Machine-0001"
    Get-CitrixMachine -MachineName "${MachineName}.example.local"
    ```
- Get session info on a machine

    ```powershell
    $MachineName = "Ops2Machine-0001"
    Get-CitrixMachineSession -MachineName "${MachineName}.example.local"
    ```

### cmdlets for delivery groups

- Get delivery group list

    ```powershell
    Get-CitrixDeliveryGroups
    ```

### cmdlets for machine catalogs

- Get machine catalog list

    ```powershell
    Get-CitrixMachineCatalogs
    ```

- Get a machine catalog info

    ```powershell
    $CatalogName = "CVAD_APIs_MCS_Catalog"
    Get-CitrixMachineCatalog -CatalogName $CatalogName
    ```

- Get machines in a machine catalog

    ```powershell
    $CatalogName = "CVAD_APIs_MCS_Catalog"
    Get-CitrixMachineCatalogMachines -CatalogName $CatalogName
    ```

### combination of cmdlets

- Move a specified virtual machine to a different delivery group in a different machine catalog

    `.example.local` is the domain suffix of the virtual machine.
    `ORCHPERFS2` is the NetBIOS domain name of the virtual machine.
    `RG-CITRIX-DAAS` is the resource group name of the virtual machine.
    `Citrix-Connect` is the name of the hypervisor connection.

    ```powershell
    # Define variables
    $DomainSuffix = "example.local"
    $NetBIOSDomainName = "ORCHPERFS2"
    $ResourceGroupName = "RG-CITRIX-DAAS"
    $PublishedName = "RemotePC"

    $UserName = "user01"
    $MachineName = "Ops2Machine-0001"

    $CurrentMachineCatalogName = "CVAD_APIs_MCS_Catalog01"
    $NewMachineCatalogName = "CVAD_APIs_MCS_Catalog02"

    $CurrentDeliveryGroupName = "CVAD_APIs_DG_Group01"
    $NewDeliveryGroupName = "CVAD_APIs_DG_Group02"

    # Remove the machine from the current delivery group
    $Machine = Get-CitrixMachine -MachineName "${MachineName}.${DomainSuffix}"
    Remove-CitrixDeliveryGroupMachine -DeliveryGroupName $CurrentDeliveryGroupName -MachineName $Machine.Id

    # Move the machine to from the current machine catalog
    Remove-CitrixMachineCatalogMachine -MachineCatalogName $CurrentMachineCatalogName -MachineName "${MachineName}.${DomainSuffix}"

    # Add the machine to the new machine catalog
    Add-CitrixMachineCatalogMachine -MachineCatalogName $NewMachineCatalogName -MachineName "${NetBIOSDomainName}\${MachineName}" -HypervisorConnection 'Citrix-Connect' -HostedMachineId "${ResourceGroupName}/${MachineName}"

    # Add the machine to the new delivery group
    Add-CitrixDeliveryGroupMachine -DeliveryGroupName $NewDeliveryGroupName -MachineName "${MachineName}.${DomainSuffix}" -MachineCatalogName $NewMachineCatalogName

    # Change the published name of the machine
    Update-CitrixMachineCatalogMachine -MachineName "${MachineName}.${DomainSuffix}" -AssignedUsers "${NetBIOSDomainName}\${UserName}" -HostedMachineId "${ResourceGroupName}/${MachineName}" -HypervisorConnection 'Citrix-Connect' -PublishedName $PublishedName
    ```
