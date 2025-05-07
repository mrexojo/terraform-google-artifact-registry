variable "repository_id" {
  description = "ID of the repository (must be unique within the project)"
  type        = string
}

variable "location" {
  description = "Region or multi-region location for the repository"
  type        = string
  default     = "us-central1"
}

variable "description" {
  description = "Description of the repository"
  type        = string
  default     = "Artifact Registry repository created with Terraform"
}

variable "format" {
  description = "Format of the repository: DOCKER, NPM, MAVEN, PYTHON, GO, GENERIC, APT, YUM, etc."
  type        = string
  default     = "DOCKER"
  validation {
    condition     = contains(["DOCKER", "NPM", "MAVEN", "PYTHON", "GO", "GENERIC", "APT", "YUM", "KFP", "ANDROID"], var.format)
    error_message = "Format must be one of: DOCKER, NPM, MAVEN, PYTHON, GO, GENERIC, APT, YUM, KFP, ANDROID."
  }
}

variable "mode" {
  description = "Mode of the repository: STANDARD_REPOSITORY (default), VIRTUAL_REPOSITORY, or REMOTE_REPOSITORY"
  type        = string
  default     = "STANDARD_REPOSITORY"
  validation {
    condition     = contains(["STANDARD_REPOSITORY", "VIRTUAL_REPOSITORY", "REMOTE_REPOSITORY"], var.mode)
    error_message = "Mode must be one of: STANDARD_REPOSITORY, VIRTUAL_REPOSITORY, or REMOTE_REPOSITORY."
  }
}

variable "encryption_key" {
  description = "Customer Managed Encryption Key (CMEK) for the repository (full name)"
  type        = string
  default     = null
}

variable "maintainer" {
  description = "Name of the maintainer of the repository"
  type        = string
}

variable "project" {
  description = "Project name or code"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "labels" {
  description = "Additional labels to attach to the repository"
  type        = map(string)
  default     = {}
}

variable "iam_bindings" {
  description = "Map of role/member pairs to add as IAM bindings"
  type        = map(list(string))
  default     = {}
}

variable "enable_private_access" {
  description = "Enable private access to the repository (requires VPC Service Controls)"
  type        = bool
  default     = false
}

variable "service_account_email" {
  description = "Service account email for private repository access"
  type        = string
  default     = ""
}

variable "enable_vulnerability_scanning" {
  description = "Enable vulnerability scanning for container images"
  type        = bool
  default     = false
}

variable "project_number" {
  description = "Project number (required for vulnerability scanning)"
  type        = string
  default     = ""
}

# Cleanup policies variables
variable "enable_cleanup_policies" {
  description = "Enable cleanup policies for the repository"
  type        = bool
  default     = false
}

variable "cleanup_package_prefixes" {
  description = "List of package name prefixes to apply cleanup policies to"
  type        = list(string)
  default     = [""]
}

variable "cleanup_keep_count" {
  description = "Number of versions to keep per package"
  type        = number
  default     = 10
}

variable "cleanup_policies" {
  description = "Map of cleanup policy configurations"
  type = map(object({
    action = string
    # Using null default values instead of optional attributes
    condition = object({
      tag_state             = string
      tag_prefixes          = list(string)
      older_than            = string
      package_name_prefixes = list(string)
    })
    most_recent_versions = object({
      package_name_prefixes = list(string)
      keep_count            = number
    })
  }))
  default = {}
}

# Virtual repository variables
variable "upstream_repositories" {
  description = "Map of upstream repositories for virtual repositories"
  type = map(object({
    repository_path = string
    priority        = number
  }))
  default = {}
}

# Remote repository variables
variable "remote_repo_description" {
  description = "Description for remote repository"
  type        = string
  default     = "Remote repository"
}

variable "remote_docker_repo" {
  description = "Public Docker repository to proxy (e.g., DOCKER_HUB)"
  type        = string
  default     = "DOCKER_HUB"
}

variable "remote_maven_repo" {
  description = "Public Maven repository to proxy (e.g., MAVEN_CENTRAL)"
  type        = string
  default     = null
}

variable "remote_npm_repo" {
  description = "Public NPM repository to proxy (e.g., NPMJS)"
  type        = string
  default     = null
}

variable "remote_python_repo" {
  description = "Public Python repository to proxy (e.g., PYPI)"
  type        = string
  default     = null
}