terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.24.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "kafka" {
  metadata {
    name = "kafka"
  }
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  version          = "v1.13.3"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "helm_release" "redpanda-controller" {
  name       = "redpanda-controller"
  repository = "https://charts.redpanda.com"
  chart      = "operator"
  namespace  = kubernetes_namespace.kafka.metadata[0].name
  set {
    name  = "image.repository"
    value = "docker.redpanda.com/redpandadata/redpanda-operator"
  }
  depends_on = [helm_release.cert_manager]
}

resource "kubernetes_manifest" "redpanda-cluster" {
  manifest   = yamldecode(file("${path.module}/redpanda-cluster.yaml"))
  depends_on = [helm_release.redpanda-controller]
}

resource "kubernetes_manifest" "redpanda-topic-input" {
  manifest   = yamldecode(file("${path.module}/redpanda-topic.yaml"))
  depends_on = [kubernetes_manifest.redpanda-cluster]
}
