# citrix-powershell
Citrix Cloud DaaS の非公式な PowerShell モジュールです。
Azure に接続された DaaS にのみ対応しています。

For English, see [README.md](README.md).

# 使い方

## API クライアントを作成する

この cmdlet を使うためには、Citrix Cloud で API クライアントを作成する必要があります。

https://developer-docs.citrix.com/en-us/citrix-cloud/citrix-cloud-api-overview/get-started-with-citrix-cloud-apis.html

## モジュールをモジュールパスに配置する

`Citrix` フォルダーを `$HOME\Documents\PowerShell\Modules` フォルダーにコピーします。
OneDrive for Business を使っている場合、フォルダーの場所は `C:\Users\xxxxxxxx\OneDrive - xxxxxxxx\Documents\PowerShell\Modules` になるかもしれません。

わたしはこのモジュールを PowerShell Gallery に公開するつもりはありません。非公式なので。

## 環境変数を定義する

```powershell
$Env:CUSTOMER_ID = "xxxxxxxx"
$Env:CLIENT_ID = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
$Env:CLIENT_SECRET = "xxxxxxxxxxxxxxxxxxxxxxxx"
```

## cmdlet を実行する

これで、cmdlet を実行できるようになります。
Citrix Cloud API に使うアクセス トークンは cmdlet によって暗黙的に取得されるので、気にする必要はありません。
すべての cmdlet が実装されているわけではなく、また、ここでドキュメント化されているわけでもありません。

### マシンに関する cmdlet

- マシンに関する情報を取得

    ```powershell
    $MachineName = "Ops2Machine-0001"
    Get-CitrixMachine -MachineName "${MachineName}.example.local"
    ```
- マシン上のセッションに関する情報を取得

    ```powershell
    $MachineName = "Ops2Machine-0001"
    Get-CitrixMachineSession -MachineName "${MachineName}.example.local"
    ```

### デリバリーグループに関する cmdlet

- デリバリーグループの一覧を取得

    ```powershell
    Get-CitrixDeliveryGroups
    ```

### マシンカタログに関する cmdlet

- マシンカタログの一覧を取得

    ```powershell
    Get-CitrixMachineCatalogs
    ```

- マシンカタログの情報を取得

    ```powershell
    $CatalogName = "CVAD_APIs_MCS_Catalog"
    Get-CitrixMachineCatalog -CatalogName $CatalogName
    ```

- マシンカタログに含まれるマシンの一覧を取得

    ```powershell
    $CatalogName = "CVAD_APIs_MCS_Catalog"
    Get-CitrixMachineCatalogMachines -CatalogName $CatalogName
    ```

### cmdlet の組み合わせ

- 仮想マシンを別のマシンカタログの別のデリバリーグループに移動する

    `.example.local` は仮想マシンのドメインサフィックスです。
    `ORCHPERFS2` は仮想マシンの NetBIOS ドメイン名です。
    `RG-CITRIX-DAAS` は仮想マシンのリソース グループ名です。
    `Citrix-Connect` はハイパーバイザー接続の名前です。

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
