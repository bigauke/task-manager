output "cluster_name" {
  value       = "task-manager-cluster"
  description = "O nome do cluster k3d criado."
}

output "grafana_port_forward_cmd" {
  value       = "kubectl port-forward svc/monitoring-kube-prometheus-grafana 3000:80 -n monitoring"
  description = "Comando para acessar o Grafana localmente."
}

output "grafana_credentials" {
  value       = "Usuário: admin | Senha: prom-operator"
  description = "Credenciais padrão do Grafana."
}

output "loki_datasource_url" {
  value       = "http://loki:3100"
  description = "URL para configurar o Loki no Grafana."
}
