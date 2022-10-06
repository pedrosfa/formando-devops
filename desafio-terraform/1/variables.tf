variable "cluster_name" {
    type="string"
    description = "Name of the KIND cluster"
}

variable "kubernetes_version" {
    type="string"
    description = "Kubernetes version to be used"
}

variable "kubernetes_priority_class_name" {
    description = "Priority class name for the kubernetes deployment for metrics server"
}

variable "metrics_server_option_kubelet_certificate_authority" {
    description = " The path of the CA certificate to use for validate the Kubelet's serving certificates for the metrics server"
}

variable "metrics_server_option_tls_cert_file" {
    description = "The serving certificate and key files. If not specified, self-signed certificates will be generated, but it's recommended that you use non-self-signed certificates in production for the metrics server"
}

variable "metrics_server_option_tls_private_key_file " {
    description = "The serving certificate and key files. If not specified, self-signed certificates will be generated, but it's recommended that you use non-self-signed certificates in production for the metrics server"
}