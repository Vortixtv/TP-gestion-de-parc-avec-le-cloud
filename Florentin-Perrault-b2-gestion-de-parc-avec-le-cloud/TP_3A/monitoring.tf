resource "azurerm_monitor_action_group" "main" {
  name                = "ag-tp3-alerts"
  resource_group_name = azurerm_resource_group.main.name
  short_name          = "vm-alerts"

  email_receiver {
    name          = "admin"
    email_address = "vortix@protonmail.com" #
  }
}

resource "azurerm_monitor_metric_alert" "cpu_alert" {
  name                = "cpu-alert-super-vm"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_linux_virtual_machine.main.id]
  description         = "Alerte si le CPU dépasse 70%"
  severity            = 2

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 70
  }

  window_size   = "PT5M"
  frequency     = "PT1M"
  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}
resource "azurerm_monitor_metric_alert" "memory_alert" {
  name                = "ram-alert-super-vm"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_linux_virtual_machine.main.id]
  description         = "Alerte si la RAM dispo est < 512Mo"
  severity            = 2

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Available Memory Bytes" # ennoctet 
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 536870912
  }

  window_size   = "PT5M"
  frequency     = "PT1M"
  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}
