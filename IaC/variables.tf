variable "webappName" {
  type    = string
  default = "app-weu-gaborka812-django"
}

variable "dockerimageName" {
  type    = string
  default = "gaborka98/django-test:latest"
}

variable "dockerRegistryUrl" {
  type    = string
  default = "registry-1.docker.io"
}

variable "extraAllowedHosts" {
  type = list(string)
  default = []
}

variable "azureSubscriptionId" {
  description = "Azure Subscription ID"
  type        = string
  default     = null
}

variable "tfStateName" {
  description = "Terraform Statefile Name"
  type        = string
  default     = "django-webapp"
}