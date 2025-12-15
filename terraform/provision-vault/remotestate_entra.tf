data "terraform_remote_state" "entra" {
  backend = "local"

  config = {
    path = "../provision-entra/terraform.tfstate"
  }
}
