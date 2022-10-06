output "api_endpoint" {
    description = "Kubernetes APIServer endpoint."
    value = kind_cluster.default.endpoint
}
    
output "kubeconfig" {
    description = "The kubeconfig for the cluster after it is created"
    value = kind_cluster.default.kubeconfig
}
    
output "client_certificate" {
    description = "Client certificate for authenticating to cluster."
    value = kind_cluster.default.client_certificate
}
    
output "client_key" {
    description = "Client key for authenticating to cluster."
    value = kind_cluster.default.client_key
}

output "cluster_ca_certificate" {
    description = "Client verifies the server certificate with this CA cert."
    value = kind_cluster.default.cluster_ca_certificate
}
