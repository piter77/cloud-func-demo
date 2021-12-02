// Configure the Google Cloud provider
provider "google" {
  credentials = file("credentials.json") // create this credentials by yourself
  project     = "my-project-cloud-func-demo"
  region      = "us-central1"
}

data "archive_file" "archive_my_jar" {
  type        = "zip"
  source_file = "${path.root}/../build/libs/cloud-func-demo-0.1-all.jar"
  output_path = "${path.module}/files/cloud-func-demo.zip"
}

resource "google_storage_bucket" "bucket" {
  name     = "cloud-func-demo-tf" # This bucket name must be unique
  location = "US"
}

resource "google_storage_bucket_object" "archive" {
  name   = "cloud-func-demo.zip"
  bucket = google_storage_bucket.bucket.name
  source = "${path.module}/files/cloud-func-demo.zip"
}

resource "google_cloudfunctions_function" "function" {
  name        = "cloud-func-demo-tf"
  description = "CLoud func Demo made with tf."
  runtime     = "java11"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  trigger_http          = true
  entry_point           = "io.micronaut.gcp.function.http.HttpFunction" # This is the name of the function that will be executed in your Python code
}

resource "google_service_account" "service_account" {
  account_id   = "cloud-func-demo-tf-invoker"
  display_name = "Cloud Function Demo Invoker Service Account"
}


resource "google_cloudfunctions_function_iam_binding" "binding" {
  project = google_cloudfunctions_function.function.project
  region = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name
  role = "roles/cloudfunctions.invoker"
  members = [
    "allUsers",
  ]
}

resource "google_cloud_scheduler_job" "job" {
  name             = "cloud-func-demo-tf-scheduler"
  description      = "Trigger the ${google_cloudfunctions_function.function.name} Cloud Function every 10 hrs."
  schedule         = "0 */20 * * *" # Every 10 hrs
  time_zone        = "Europe/Dublin"
  attempt_deadline = "320s"

  http_target {
    http_method = "GET"
    uri         = "${google_cloudfunctions_function.function.https_trigger_url}/cloudFuncDemo/time"

    oidc_token {
      service_account_email = google_service_account.service_account.email
    }
  }
}