---
inclusion: always
---

# Technology Stack

## Backend
- Java 21 + Spring Boot 3.x
- Kafka for async messaging (topic naming: [domain].[entity].[event])
- PostgreSQL 15 (primary), Redis (cache/session)
- Flyway for migrations — NO manual DDL ever

## Frontend  
- TypeScript + React 18 + Vite
- Component library: [your library]

## Infra
- Kubernetes (EKS), Helm, ArgoCD, Terraform

## Mandatory Patterns
- Hexagonal architecture in all backend services
- All cross-service comms via Kafka (no sync HTTP in hot paths)
- OpenAPI 3.x spec required for all public REST APIs
- Secrets via AWS Secrets Manager — never env vars

## Forbidden Patterns
- Direct DB access across service boundaries
- Synchronous HTTP between backend services in critical paths
- Hardcoded configuration — use ConfigMaps/Secrets