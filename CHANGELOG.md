# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-03-19

### Added
- Initial release
- Basic Redis master-replica setup
- Vault HA cluster with Raft storage
- TLS encryption for Redis and Vault
- Monitoring with Prometheus and Grafana
- Backup and restore scripts
- Kubernetes deployment examples
- Comprehensive documentation
- GitHub Actions workflows
- Security best practices
- Contributing guidelines

### Security
- TLS encryption for all services
- Password authentication for Redis
- Token-based authentication for Vault
- Network policies for Kubernetes
- RBAC configurations
- Audit logging
- Certificate management

### Documentation
- Architecture documentation
- Security guide
- Kubernetes setup guide
- GitHub repository setup guide
- Contributing guidelines
- Code of conduct
- License (MIT)

### Infrastructure
- Docker Compose setup
- Kubernetes manifests
- Monitoring stack
- Backup scripts
- Helper scripts
- CI/CD pipelines

### Development
- GitHub Actions workflows
- Code linting
- Security scanning
- Automated testing
- Release automation
- Changelog generation

## [Unreleased]
### Added
- Comprehensive test suite (unit, integration, performance) for Redis and Vault configuration and integration.

### Improved
- Kubernetes YAMLs now enforce pod-level securityContext (`runAsNonRoot`, `runAsRoot`) for enhanced security. 