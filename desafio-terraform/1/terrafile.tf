module "metrics-server" {
    source = "cookielab/metrics-server/kubernetes"
    
    kubernetes_priority_class_name = var.kubernetes_priority_class_name
    metrics_server_option_tls_cert_file = var.metrics_server_option_tls_cert_file 
    metrics_server_option_tls_private_key_file = var.metrics_server_option_tls_private_key_file 
    metrics_server_option_kubelet_certificate_authority = var.metrics_server_option_kubelet_certificate_authority
}