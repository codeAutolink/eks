
variable "region" {
  description = "AWS region to deploy resources to"
  default     = "eu-west-2"
}

variable "prefix" {
  description = "Prefix to be assigned to resources."
  default     = "django-k8s"
}

variable "db_password" {
  description = "Password for the RDS database instance."
  default     = "samplepassword123"
}


variable "kube_config_path" {
  description = "Chemin vers le fichier de configuration Kubernetes"
  type        = string
  
  // Vous pouvez fournir une valeur par défaut ici ou la laisser vide pour la définir ailleurs
  default     = ""
}


variable "velero_cloud_credentials" {
  description = "Path to the Velero cloud credentials file"
  type        = string
}

