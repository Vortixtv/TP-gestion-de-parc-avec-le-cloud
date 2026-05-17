resource "azurerm_storage_account" "main" {
  name                     = "storagevortix2156"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "meowcontainer" {
  name                  = "backups"
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}

data "azurerm_virtual_machine" "main" {
  name                = azurerm_linux_virtual_machine.main.name
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_role_assignment" "vm_blob_access" {
  scope                = azurerm_storage_account.main.id
  role_definition_name = "Storage Blob Data Contributor"
  
  principal_id         = data.azurerm_virtual_machine.main.identity[0].principal_id

  depends_on = [
    azurerm_linux_virtual_machine.main
  ]
}
