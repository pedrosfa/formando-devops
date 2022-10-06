provider "kind" {}

resource "kind_cluster" "default" {
    name = var.cluster_name
    node_image = "kindest/node:v${var.kubernetes_version}"

    kind_config {
        kind = "Cluster"
        api_version = "kind.x-k8s.io/v1alpha4"
        node {
            role = "control-plane"
        }
        node {
            role = "worker"
        }
        node {
            role = "infra"
            
        }
        node {
            role = "app"
        }
    }

    provisioner "local-exec" {
        command = "kubectl taint node ${var.cluster_name}-control-plane dedicated=infra:NoSchedule"
    }
}