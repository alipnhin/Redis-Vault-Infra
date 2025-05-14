# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-05-14

### Added
- Initial release of Redis-Vault-Infra
- Redis master-replica setup with Sentinel for high availability
- Vault HA cluster with Raft storage backend
- TLS encryption for secure communication
- Comprehensive monitoring setup with Prometheus and Grafana
- Backup and restore functionality
- Kubernetes deployment support
- Detailed documentation including:
  - Architecture overview
  - Security guidelines
  - Installation guide
  - Kubernetes deployment guide
  - Troubleshooting guide
- Comprehensive test suite (unit, integration, performance) for Redis and Vault configuration and integration

### Security
- TLS encryption for all services
- Secure password management
- Role-based access control
- Audit logging
- Automatic unsealing for Vault

### Infrastructure
- Docker and Docker Compose support
- Kubernetes manifests
- Monitoring stack:
  - Prometheus for metrics collection
  - Grafana for visualization
  - AlertManager for notifications
- Backup solutions for both Redis and Vault

### Documentation
- Comprehensive README with setup instructions
- Architecture documentation
- Security best practices
- Contributing guidelines
- License information
- Troubleshooting guide

### Improved
- Kubernetes YAMLs now enforce pod-level securityContext (`runAsNonRoot`, `runAsRoot`) for enhanced security

[1.0.0]: https://github.com/alipnhin/Redis-Vault-Infra/releases/tag/v1.0.0 