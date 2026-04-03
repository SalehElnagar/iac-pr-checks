resource "azurerm_monitor_diagnostic_setting" "this" {
  name                           = local.name
  target_resource_id             = var.target_resource_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = var.log_analytics_destination_type

  dynamic "enabled_log" {
    for_each = var.enabled_logs

    content {
      category       = try(enabled_log.value.category, null)
      category_group = try(enabled_log.value.category_group, null)
    }
  }

  dynamic "metric" {
    for_each = var.metrics

    content {
      category = metric.value.category
      enabled  = try(metric.value.enabled, true)
    }
  }
}
