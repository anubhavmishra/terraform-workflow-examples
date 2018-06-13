##### Remote state in GCS #####
terraform {
  backend "gcs" {
    bucket = "terraform-workflow-example"
    prefix = "terraform/state"
  }
}
