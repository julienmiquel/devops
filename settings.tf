

data "terraform_remote_state" "remote_tf_states" {
  backend = "gcs"
  config = {
    bucket  = var.gcs_tf_state
    prefix  = format("env_%s", var.tag)
  }
}


