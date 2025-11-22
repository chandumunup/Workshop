CI / Local build guide

This document describes how to build microservices locally, create Docker images, create Helm charts, and push images to GCR/ACR.

Prerequisites
- Docker
- (Optional for Java) Maven and JDK 17
- (Optional for Node services) Node.js and npm
- kubectl and Helm for deploying charts

Build locally
- Java (order-service): mvn -B -DskipTests package -f order-service/pom.xml
- Node services: npm install (in each service folder) and then node src/index.js

Build images and optionally push
Use the PowerShell script at `scripts\build_and_push.ps1`.

Examples:
# Build images and push to GCR
.
# .\scripts\build_and_push.ps1 -Registry "gcr.io" -Project "my-project" -Tag "v1" -Push

# Build images and push to ACR
# .\scripts\build_and_push.ps1 -Registry "myacr.azurecr.io" -Project "myproj" -Tag "v1" -Push

Helm charts
- Charts are available under `helm-charts/` for each service. Update `values.yaml` image.repository to point to your registry before deploying.

Deploy with Helm (example):
- helm install app application-service -f helm-charts/application-service/values.yaml helm-charts/application-service

Notes
- The Node services include minimal `package.json` files so Docker builds succeed. If you want to add more dependencies, update the package.json files in each service folder.
