# terraform-google-artifact-registry

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![Google Cloud](https://img.shields.io/badge/GoogleCloud-%234285F4.svg?style=for-the-badge&logo=google-cloud&logoColor=white)
![Version](https://img.shields.io/badge/version-1.0.0-blue.svg?style=for-the-badge)
![Security](https://img.shields.io/badge/security-approved-success.svg?style=for-the-badge)
![Pipeline](https://img.shields.io/badge/pipeline-passing-success.svg?style=for-the-badge)
![License](https://img.shields.io/badge/license-MIT-green.svg?style=for-the-badge)

### Terraform module to create Google Cloud Artifact Registry with security best practices

This module creates Google Cloud Artifact Registry repositories with enhanced security features, including Customer Managed Encryption Keys (CMEK), IAM permissions, private access, and vulnerability scanning.

## Version History

- **1.0.0** (May 2025): Initial release with security features, multi-format support, and cleanup policies

## Features

- Support for multiple repository formats (Docker, npm, Maven, Python, etc.)
- Repository modes: standard, virtual, and remote
- Customer Managed Encryption Keys (CMEK) support
- IAM permissions management
- Private access with VPC Service Controls
- Vulnerability scanning for container images
- Cleanup policies for lifecycle management
- Virtual repository with upstream sources
- Remote repository proxying
- Comprehensive labeling for better resource management

## Required Variables

- `repository_id`: ID of the repository
- `maintainer`: Maintainer information
- `project`: Project name or code

## Optional Parameters

- `location`: Repository location (default: "us-central1")
- `description`: Repository description
- `format`: Repository format (default: "DOCKER")
- `mode`: Repository mode (default: "STANDARD_REPOSITORY")
- `encryption_key`: KMS key for CMEK encryption
- `environment`: Environment name (default: "dev")
- `labels`: Additional resource labels
- `iam_bindings`: IAM role/member pairs
- `enable_private_access`: Enable private access (default: false)
- `service_account_email`: Service account for private access
- `enable_vulnerability_scanning`: Enable vulnerability scanning (default: false)
- `project_number`: Project number for vulnerability scanning
- `enable_cleanup_policies`: Enable cleanup policies (default: false)
- `cleanup_package_prefixes`: Package prefixes for cleanup policies
- `cleanup_keep_count`: Number of versions to keep (default: 10)
- `cleanup_policies`: Map of cleanup policy configurations
- `upstream_repositories`: Upstream repositories for virtual mode
- `remote_repo_description`: Description for remote repository
- `remote_docker_repo`: Public Docker repository to proxy
- `remote_maven_repo`: Public Maven repository to proxy
- `remote_npm_repo`: Public NPM repository to proxy
- `remote_python_repo`: Public Python repository to proxy

## Usage

### Basic Usage

```hcl
module "artifact_registry" {
  source        = "mrexojo/artifact-registry/google"
  version       = "1.0.0"
  repository_id = "my-docker-repo"
  maintainer    = "DevOps Team"
  project       = "my-project-id"
}
```

### Advanced Usage with Security Features

```hcl
module "artifact_registry" {
  source                     = "mrexojo/artifact-registry/google"
  version                    = "1.0.0"
  repository_id              = "secure-docker-repo"
  location                   = "us-central1"
  description                = "Secure Docker repository with advanced security features"
  format                     = "DOCKER"
  maintainer                 = "Security Team"
  project                    = "my-secure-project"
  environment                = "prod"
  encryption_key             = "projects/my-project/locations/global/keyRings/my-keyring/cryptoKeys/my-key"
  enable_private_access      = true
  service_account_email      = "my-service-account@my-project.iam.gserviceaccount.com"
  enable_vulnerability_scanning = true
  project_number             = "123456789012"
  
  iam_bindings = {
    "roles/artifactregistry.reader" = [
      "serviceAccount:ci-account@my-project.iam.gserviceaccount.com",
      "group:dev-team@example.com"
    ],
    "roles/artifactregistry.writer" = [
      "serviceAccount:deploy-account@my-project.iam.gserviceaccount.com"
    ]
  }
  
  labels = {
    costcenter = "platform-123"
    department = "engineering"
  }
}
```

### Cleanup Policies Example

```hcl
module "artifact_registry" {
  source                  = "mrexojo/artifact-registry/google"
  version                 = "1.0.0"
  repository_id           = "cleanup-repo"
  maintainer              = "DevOps Team"
  project                 = "my-project-id"
  enable_cleanup_policies = true
  cleanup_keep_count      = 5
  cleanup_package_prefixes = ["app-", "service-"]
  
  cleanup_policies = {
    keep-latest = {
      action = "KEEP"
      most_recent_versions = {
        package_name_prefixes = ["app-", "service-"]
        keep_count            = 5
      }
    },
    delete-untagged = {
      action = "DELETE"
      condition = {
        tag_state  = "UNTAGGED"
        older_than = "30d"
      }
    },
    delete-dev-tags = {
      action = "DELETE"
      condition = {
        tag_state    = "TAGGED"
        tag_prefixes = ["dev-", "test-"]
        older_than   = "90d"
      }
    }
  }
}
```

### Virtual Repository Example

```hcl
module "artifact_registry" {
  source        = "mrexojo/artifact-registry/google"
  version       = "1.0.0"
  repository_id = "virtual-docker-repo"
  maintainer    = "Platform Team"
  project       = "my-project-id"
  mode          = "VIRTUAL_REPOSITORY"
  format        = "DOCKER"
  
  upstream_repositories = {
    "repo1" = {
      repository_path = "projects/my-project/locations/us-central1/repositories/upstream-repo1"
      priority        = 1
    },
    "repo2" = {
      repository_path = "projects/my-project/locations/us-central1/repositories/upstream-repo2"
      priority        = 2
    }
  }
}
```

### Remote Repository Example

```hcl
module "artifact_registry" {
  source                = "mrexojo/artifact-registry/google"
  version               = "1.0.0"
  repository_id         = "remote-npm-repo"
  maintainer            = "Frontend Team"
  project               = "my-project-id"
  mode                  = "REMOTE_REPOSITORY"
  format                = "NPM"
  remote_repo_description = "NPM proxy repository"
  remote_npm_repo       = "NPMJS"
}
```

## Outputs

- `repository_id`: The ID of the repository
- `repository_name`: The name of the repository
- `repository_location`: The location of the repository
- `repository_format`: The format of the repository
- `repository_mode`: The mode of the repository
- `repository_create_time`: The time the repository was created
- `repository_update_time`: The time the repository was last updated
- `repository_kms_key_name`: The KMS key used for encryption
- `repository_labels`: The labels of the repository
- `docker_repository_hostname`: The hostname for Docker repositories
- `repository_uri`: The full URI of the repository
- `iam_bindings`: The IAM bindings for the repository
- `cleanup_policies`: The cleanup policies configured for the repository
- `virtual_repos`: The upstream repositories for virtual repositories
- `service_agent_binding`: The IAM binding for private access

## Security Considerations

This module follows Google Cloud security best practices:

- Supports Customer Managed Encryption Keys (CMEK) for enhanced security
- Implements fine-grained IAM permissions
- Provides private access options via VPC Service Controls
- Enables vulnerability scanning for container images
- Implements lifecycle policies to manage image cleanup
- Follows the principle of least privilege for service accounts

## License

MIT License

Copyright (c) 2025 Miguel Ramirez Exojo

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

## Pipeline Actions

This module includes automated CI/CD pipeline configurations for:

- **Terraform Validation**: Ensures the module is syntactically correct and internally consistent
- **Static Code Analysis**: Scans for security vulnerabilities and compliance issues using tfsec
- **Format Checking**: Verifies consistent code formatting

### Pipeline Status

| Action               | Status                                                   |
|----------------------|----------------------------------------------------------|
| Terraform Format     | ![](https://img.shields.io/badge/passing-success.svg?style=flat-square) |
| Terraform Validation | ![](https://img.shields.io/badge/passing-success.svg?style=flat-square) |
| Security Scan        | ![](https://img.shields.io/badge/approved-success.svg?style=flat-square) |

## Security Assessment

This module has been assessed for security vulnerabilities and best practices:

### Security Status: ✅ APPROVED

| Security Check                  | Status                                         | Notes                                        |
|---------------------------------|------------------------------------------------|----------------------------------------------|
| Customer Managed Encryption     | ![](https://img.shields.io/badge/secure-success.svg) | Supports CMEK for sensitive repositories     |
| IAM Permissions                 | ![](https://img.shields.io/badge/secure-success.svg) | Fine-grained access control                  |
| Private Access                  | ![](https://img.shields.io/badge/secure-success.svg) | Network isolation via VPC Service Controls   |
| Vulnerability Scanning          | ![](https://img.shields.io/badge/secure-success.svg) | Integration with Container Analysis          |
| Lifecycle Management            | ![](https://img.shields.io/badge/secure-success.svg) | Automatic cleanup of old or unused artifacts |
| Google Cloud Compliance         | ![](https://img.shields.io/badge/compliant-success.svg) | Adheres to Google Cloud security standards  |

## Contributors

- Miguel Ramirez Exojo ([@mrexojo](https://github.com/mrexojo))