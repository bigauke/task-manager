resource "kubernetes_config_map" "task_manager_dashboard" {
  depends_on = [kubernetes_namespace.monitoring]

  metadata {
    name      = "task-manager-dashboard"
    namespace = "monitoring"
    labels = {
      grafana_dashboard = "1"
    }
  }

  data = {
    "task-manager.json" = file("${path.module}/grafana_dashboard.json")
  }
}
