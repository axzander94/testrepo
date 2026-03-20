---
inclusion: always
---

# Technology Stack

## Backend
- Net version 8	
- C# version 12	
- NPoco version5.7.1 Micro ORM
- AutoMapper version 13.0.1	
- Serilog version 8.0.2	
- Sentry version 4.10.2
- Database MS SQL Server 2022

## Frontend  
- TypeScript 5 + React 18
- Component library: [your library]
- Emotion version 11
- Ky version 0.32
- Xstate version 4
- New Relic

## Dev Tools
- Nx version 16	
- Storybook version 7	
- Eslint version 8	
- Jest version 29	
- Prettier version 2
- NodeJS version 20	
- NUnit version 4.2.2

## Infra
- AWS S3
- AWS Lambda@Edge
- AWS CloudFront
- AWS Load Balancer
- AWS ECS Fargate
- AWS RDS (SQL Server)
- AWS Secrets Manager
- AWS ElastiCache (Redis)
- AWS SES
- Terraform
- Akamai
- Amazon Cognito
- AWS WAF
- Pipeline - Jenkins
- Storage bitbucket
- Amazon Route53
- Azure EntraID
- AWS Certificate Manager
- AWS ECR

## Third Party integrations
- Google Tag Manager
- Google analytics
- One Trust Cookies manager
- Sentry
- New Relic
- OpsGenie
- YOTI
- Third Party Databases of PMI Which store customer data


## Mandatory Patterns
- Hexagonal architecture in all backend services
- OpenAPI 3.x spec required for all public REST APIs
- Secrets via AWS Secrets Manager — never env vars

## Forbidden Patterns
- Direct DB access across service boundaries
- Personal or sensetive data storage
- Synchronous HTTP between backend services in critical paths
- Hardcoded configuration — use ConfigMaps/Secrets