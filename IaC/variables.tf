variable "webappName" {
  type    = string
  default = "app-weu-gaborka812-django"
}

variable "dockerimageName" {
  type    = string
  default = "docker.io/gaborka98/django-test:latest"
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