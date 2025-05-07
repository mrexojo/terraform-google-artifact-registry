output "repository_id" {
  description = "The ID of the repository"
  value       = google_artifact_registry_repository.repository.repository_id
}

output "repository_name" {
  description = "The name of the repository"
  value       = google_artifact_registry_repository.repository.name
}

output "repository_location" {
  description = "The location of the repository"
  value       = google_artifact_registry_repository.repository.location
}

output "repository_format" {
  description = "The format of the repository"
  value       = google_artifact_registry_repository.repository.format
}

output "repository_mode" {
  description = "The mode of the repository"
  value       = google_artifact_registry_repository.repository.mode
}

output "repository_create_time" {
  description = "The time the repository was created"
  value       = google_artifact_registry_repository.repository.create_time
}

output "repository_update_time" {
  description = "The time the repository was last updated"
  value       = google_artifact_registry_repository.repository.update_time
}

output "repository_kms_key_name" {
  description = "The Cloud KMS encryption key that's used to encrypt the contents of the repository"
  value       = google_artifact_registry_repository.repository.kms_key_name
}

output "repository_labels" {
  description = "The labels of the repository"
  value       = google_artifact_registry_repository.repository.labels
}

output "docker_repository_hostname" {
  description = "The hostname for Docker images in this repository (only applicable for DOCKER repositories)"
  value       = var.format == "DOCKER" ? "${google_artifact_registry_repository.repository.location}-docker.pkg.dev" : null
}

output "repository_uri" {
  description = "The URI of the repository"
  value       = var.format == "DOCKER" ? "${google_artifact_registry_repository.repository.location}-docker.pkg.dev/${var.project}/${google_artifact_registry_repository.repository.repository_id}" : null
}

output "iam_bindings" {
  description = "The IAM bindings for the repository"
  value       = google_artifact_registry_repository_iam_binding.bindings
}

output "cleanup_policies" {
  description = "The cleanup policies configured for the repository"
  value       = var.cleanup_policies
}

output "virtual_repos" {
  description = "The upstream repositories configured for a virtual repository"
  value       = var.mode == "VIRTUAL_REPOSITORY" ? var.upstream_repositories : null
}

output "service_agent_binding" {
  description = "The IAM binding for the service agent (if private access is enabled)"
  value       = var.enable_private_access ? google_artifact_registry_repository_iam_member.service_agent_binding : null
}