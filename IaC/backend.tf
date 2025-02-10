terraform {
  backend "http" {
    address        = "https://gitlab.sativus.uk/api/v4/projects/8/terraform/state/${var.tfStateName}"
    lock_address   = "https://gitlab.sativus.uk/api/v4/projects/8/terraform/state/${var.tfStateName}/lock"
    unlock_address = "https://gitlab.sativus.uk/api/v4/projects/8/terraform/state/${var.tfStateName}/lock"
    username       = "gaborka98"
    password       = ""
    lock_method    = "POST"
    unlock_method  = "DELETE"
    retry_wait_min = 5
  }
}