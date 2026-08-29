terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.14.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "null_resource" "k3d_cluster" {
  triggers = {
    cluster_name = "task-manager-cluster"
  }

  provisioner "local-exec" {
    command = "k3d cluster create ${self.triggers.cluster_name} --api-port 6550 -p 8081:80@loadbalancer --wait"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "k3d cluster delete ${self.triggers.cluster_name}"
  }
}

# Wait for the cluster to be fully ready before deploying anything
resource "null_resource" "wait_for_cluster" {
  depends_on = [null_resource.k3d_cluster]

  provisioner "local-exec" {
    command = "Start-Sleep -Seconds 15"
    interpreter = ["PowerShell", "-Command"]
  }
}

resource "kubernetes_namespace" "monitoring" {
  depends_on = [null_resource.wait_for_cluster]
  metadata {
    name = "monitoring"
  }
}

resource "kubernetes_namespace" "app" {
  depends_on = [null_resource.wait_for_cluster]
  metadata {
    name = "app"
  }
}

resource "helm_release" "prometheus" {
  depends_on = [kubernetes_namespace.monitoring]
  name       = "monitoring"
  namespace  = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  timeout    = 900
  wait       = false
  
  set {
    name  = "grafana.service.type"
    value = "ClusterIP"
  }

  set {
    name  = "grafana.additionalDataSources[0].name"
    value = "Loki"
  }
  set {
    name  = "grafana.additionalDataSources[0].type"
    value = "loki"
  }
  set {
    name  = "grafana.additionalDataSources[0].url"
    value = "http://loki:3100"
  }
  set {
    name  = "grafana.additionalDataSources[0].access"
    value = "proxy"
  }
}

resource "helm_release" "loki" {
  depends_on = [kubernetes_namespace.monitoring]
  name       = "loki"
  namespace  = "monitoring"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-stack"
  wait       = false

  set {
    name  = "grafana.enabled"
    value = "false"
  }
  set {
    name  = "prometheus.enabled"
    value = "false"
  }
  set {
    name  = "promtail.enabled"
    value = "true"
  }
}

resource "kubernetes_deployment" "task_manager" {
  depends_on = [kubernetes_namespace.app]
  wait_for_rollout = false

  metadata {
    name      = "task-manager"
    namespace = "app"
    labels = {
      app = "task-manager"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "task-manager"
      }
    }
    template {
      metadata {
        labels = {
          app = "task-manager"
        }
      }
      spec {
        container {
          image = "bigauke/task-manager:latest"
          name  = "task-manager"
          image_pull_policy = "Always"
          port {
            container_port = 3000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "task_manager_svc" {
  depends_on = [kubernetes_deployment.task_manager]

  metadata {
    name      = "task-manager"
    namespace = "app"
  }

  spec {
    selector = {
      app = "task-manager"
    }
    port {
      port        = 80
      target_port = 3000
    }
    type = "ClusterIP"
  }
}
