locals {
  project_name              = "postgresql-workload-id"
  location                  = "northeurope"
  authorized_ip             = ""
  psql_entra_id_admin_email = ""
  tags = {
    owner      = "Name Surname"
    created_by = "Terraform"
  }
}
