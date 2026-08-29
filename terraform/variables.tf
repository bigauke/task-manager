variable "cluster_name" {
  type        = string
  description = "Nome do cluster k3d"
  default     = "task-manager-cluster"
}

variable "app_namespace" {
  type        = string
  description = "Namespace para a aplicação task-manager"
  default     = "app"
}

variable "monitoring_namespace" {
  type        = string
  description = "Namespace para a stack de observabilidade"
  default     = "monitoring"
}
