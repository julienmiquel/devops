

data "terraform_remote_state" "remote_tf_states" {
  backend = "gcs"
  config = {
    bucket  = "tf_state_devops_hackathon_cagip"
    prefix  = format("env_%s", var.tag)
  }
}


terraform {
  backend "gcs" {
    bucket  = "tf_state_devops_hackathon_cagip"
    prefix  = "terraform/state"
  }
}
