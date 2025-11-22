<#
PowerShell helper to build and push service images to GCR.
Usage:
  .\push_to_gcr.ps1 -Project "my-gcp-project" -Tag "v1" -Services application-service,patient-service
#>
param(
  [string]$Project = "",
  [string]$Tag = "latest",
  [string[]]$Services = @("application-service","patient-service","order-service"),
  [switch]$UseServiceAccount
)

if (-not $Project) {
  Write-Host "Please provide -Project <gcp-project-id>" -ForegroundColor Yellow
  exit 1
}

if ($UseServiceAccount) {
  Write-Host "Activating service account from GOOGLE_APPLICATION_CREDENTIALS or environment..."
  # assumes env var GOOGLE_APPLICATION_CREDENTIALS points to JSON file or user ran gcloud auth
  if (-not (Get-Command gcloud -ErrorAction SilentlyContinue)) {
    Write-Host "gcloud not found in PATH. Install Google Cloud SDK to authenticate." -ForegroundColor Yellow
    exit 1
  }
}

# configure docker to use gcloud credential helper
if (Get-Command gcloud -ErrorAction SilentlyContinue) {
  gcloud auth configure-docker --quiet
} else {
  Write-Host "gcloud CLI not found. Please install Google Cloud SDK and run 'gcloud auth login' then 'gcloud auth configure-docker'" -ForegroundColor Yellow
  exit 1
}

$root = Split-Path -Parent $MyInvocation.MyCommand.Definition

foreach ($svc in $Services) {
  $svcPath = Join-Path $root $svc
  if (-not (Test-Path $svcPath)) {
    Write-Host "Service folder $svcPath not found, skipping." -ForegroundColor Yellow
    continue
  }
  $image = "gcr.io/$Project/$svc:$Tag"
  Write-Host "Building $svc -> $image"
  docker build -t $image $svcPath
  if ($LASTEXITCODE -ne 0) { Write-Host "Docker build failed for $svc" -ForegroundColor Red; exit 1 }
  Write-Host "Pushing $image"
  docker push $image
  if ($LASTEXITCODE -ne 0) { Write-Host "Docker push failed for $svc" -ForegroundColor Red; exit 1 }
}

Write-Host "All done. Images pushed to gcr.io/$Project" -ForegroundColor Green
