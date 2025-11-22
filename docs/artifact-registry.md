Artifact Registry: setup and GitHub secrets

This document explains how to create a Docker Artifact Registry in GCP and configure GitHub Secrets for the CI workflow that pushes images and deploys Helm charts.

1) Create Artifact Registry repository
- Example creating a Docker repository in `us-central1`:

```bash
gcloud artifacts repositories create microservices-repo \
  --repository-format=docker --location=us-central1 --description="Docker repo for microservices"
```

2) Grant permissions to a service account
- Create service account and grant roles:

```bash
gcloud iam service-accounts create cicd-bot --display-name "CI CD Bot"
# grant Artifact Registry writer and GKE permissions as needed
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member=serviceAccount:cicd-bot@YOUR_PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/artifactregistry.reader
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member=serviceAccount:cicd-bot@YOUR_PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/artifactregistry.writer
# additional roles for GKE deploys
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member=serviceAccount:cicd-bot@YOUR_PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/container.developer
```

3) Create and download service account key

```bash
gcloud iam service-accounts keys create key.json \
  --iam-account=cicd-bot@YOUR_PROJECT_ID.iam.gserviceaccount.com
```

4) Add GitHub repository secrets
- In your GitHub repository Settings → Secrets → Actions, add these secrets:
  - `GCP_SA_KEY`: the full JSON contents of `key.json` (copy and paste)
  - `GCP_PROJECT`: your GCP project id (e.g. `my-project`)
  - `AR_LOCATION`: Artifact Registry region (e.g. `us-central1`)
  - `AR_REPOSITORY`: the repository name (e.g. `microservices-repo`)
  - (Optional) `GKE_CLUSTER` and `GKE_LOCATION` for automatic Helm deploys

5) Local testing
- Authenticate and configure Docker to push to Artifact Registry:

```powershell
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
gcloud auth configure-docker
```

- Build and push an image locally (example):

```powershell
docker build -t us-central1-docker.pkg.dev/YOUR_PROJECT_ID/microservices-repo/application-service:local application-service
docker push us-central1-docker.pkg.dev/YOUR_PROJECT_ID/microservices-repo/application-service:local
```

6) Update Helm values or k8s manifests
- The CI workflow sets image repositories automatically when deploying with Helm.
- If you prefer to edit files directly, set the image repository to:

```
<AR_LOCATION>-docker.pkg.dev/<GCP_PROJECT>/<AR_REPOSITORY>/<service>:<tag>
```

Example: `us-central1-docker.pkg.dev/my-project/microservices-repo/application-service:sha1234`

That's it — with the service account key in `GCP_SA_KEY` and the other secrets set, the `ci-cd-ar-helm.yml` workflow will build images, push to Artifact Registry and optionally deploy your Helm charts to GKE.
