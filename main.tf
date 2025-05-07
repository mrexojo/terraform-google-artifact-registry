# Google Cloud Artifact Registry Configuration template:
# - Repository with multiple formats support (Docker, npm, Maven, etc.)
# - Security features (IAM permissions, CMEK encryption)
# - Virtual Private Cloud peering
# - Vulnerability scanning
# Author: @mrexojo
# Last update: May 2025
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository

# Required provider configuration
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
  }
  required_version = ">= 1.0.0"
}

# Main Artifact Registry resource
resource "google_artifact_registry_repository" "repository" {
  location      = var.location
  repository_id = var.repository_id
  description   = var.description
  format        = var.format

  # Only apply KMS key if encryption_key is provided
  kms_key_name = var.encryption_key != null ? var.encryption_key : null

  # Optional mode configuration (standard or virtual)
  mode = var.mode

  # Configure cleanup policies if enabled
  dynamic "cleanup_policy_dry_run" {
    for_each = var.enable_cleanup_policies ? [1] : []
    content {
      action = "KEEP"
      most_recent_versions {
        package_name_prefixes = var.cleanup_package_prefixes
        keep_count            = var.cleanup_keep_count
      }
    }
  }

  dynamic "cleanup_policies" {
    for_each = var.cleanup_policies
    content {
      id     = cleanup_policies.key
      action = cleanup_policies.value.action

      # Manejo condicional del bloque condition
      dynamic "condition" {
        # Solo crear el bloque si tenemos al menos un valor no vacío
        for_each = contains(keys(cleanup_policies.value), "condition") ? [1] : []
        content {
          tag_state             = try(cleanup_policies.value.condition.tag_state, "")
          tag_prefixes          = try(cleanup_policies.value.condition.tag_prefixes, [])
          older_than            = try(cleanup_policies.value.condition.older_than, "")
          package_name_prefixes = try(cleanup_policies.value.condition.package_name_prefixes, [])
        }
      }

      # Manejo condicional del bloque most_recent_versions
      dynamic "most_recent_versions" {
        # Solo crear el bloque si tenemos al menos un valor no vacío
        for_each = contains(keys(cleanup_policies.value), "most_recent_versions") ? [1] : []
        content {
          package_name_prefixes = try(cleanup_policies.value.most_recent_versions.package_name_prefixes, [])
          keep_count            = try(cleanup_policies.value.most_recent_versions.keep_count, 0)
        }
      }
    }
  }

  # Optional VPC configuration
  dynamic "virtual_repository_config" {
    for_each = var.mode == "VIRTUAL_REPOSITORY" ? [1] : []
    content {
      dynamic "upstream_policies" {
        for_each = var.upstream_repositories
        content {
          id         = upstream_policies.key
          repository = upstream_policies.value.repository_path
          priority   = upstream_policies.value.priority
        }
      }
    }
  }

  # Optional remote repository configuration
  dynamic "remote_repository_config" {
    for_each = var.mode == "REMOTE_REPOSITORY" ? [1] : []
    content {
      description = var.remote_repo_description
      dynamic "docker_repository" {
        for_each = var.format == "DOCKER" ? [1] : []
        content {
          public_repository = var.remote_docker_repo
        }
      }

      dynamic "maven_repository" {
        for_each = var.format == "MAVEN" && var.remote_maven_repo != null ? [1] : []
        content {
          public_repository = var.remote_maven_repo
        }
      }

      dynamic "npm_repository" {
        for_each = var.format == "NPM" && var.remote_npm_repo != null ? [1] : []
        content {
          public_repository = var.remote_npm_repo
        }
      }

      dynamic "python_repository" {
        for_each = var.format == "PYTHON" && var.remote_python_repo != null ? [1] : []
        content {
          public_repository = var.remote_python_repo
        }
      }
    }
  }

  labels = merge(
    var.labels,
    {
      created_by  = "terraform"
      maintainer  = var.maintainer
      project     = var.project
      environment = var.environment
    }
  )
}

# IAM policy bindings for the repository
resource "google_artifact_registry_repository_iam_binding" "bindings" {
  for_each   = var.iam_bindings
  location   = google_artifact_registry_repository.repository.location
  repository = google_artifact_registry_repository.repository.name
  role       = each.key
  members    = each.value
}

# VPC peering for private access if required
resource "google_artifact_registry_repository_iam_member" "service_agent_binding" {
  count      = var.enable_private_access ? 1 : 0
  location   = google_artifact_registry_repository.repository.location
  repository = google_artifact_registry_repository.repository.name
  role       = "roles/artifactregistry.serviceAgent"
  member     = "serviceAccount:${var.service_account_email}"
}

# Configure vulnerability scanning if enabled
resource "google_artifact_registry_repository_iam_binding" "vulnerability_scanning" {
  count      = var.enable_vulnerability_scanning ? 1 : 0
  location   = google_artifact_registry_repository.repository.location
  repository = google_artifact_registry_repository.repository.name
  role       = "roles/artifactregistry.vulnerabilityScanner"
  members    = ["serviceAccount:service-${var.project_number}@gcp-sa-ondemand-scanning.iam.gserviceaccount.com"]
}