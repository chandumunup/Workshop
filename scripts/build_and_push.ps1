<#
PowerShell script to build services, build Docker images and optionally push to a registry.
Usage examples:
  .\build_and_push.ps1 -Registry "gcr.io/my-project" -Project "my-project" -Tag "v1" -Push
  .\build_and_push.ps1 -Registry "myacr.azurecr.io" -Project "myproj" -Tag "v1"
#>
param(
  [string]$Registry = "",
  [string]$Project = "",
  [string]$Tag = "latest",
  [switch]$Push
)

if (-not $Registry) {
  Write-Host "Registry not provided. Set -Registry <registry> (e.g. gcr.io/my-project or myacr.azurecr.io)"
}

$root = Split-Path -Parent $MyInvocation.MyCommand.Definition

# 1) Build Java service
Write-Host "Building order-service (Maven)..."
Push-Location (Join-Path $root "order-service")
if (Get-Command mvn -ErrorAction SilentlyContinue) {
  mvn -B -DskipTests package
} else {
  Write-Host "mvn not found in PATH. Please install Maven to build order-service or build separately." -ForegroundColor Yellow
}
Pop-Location

# 2) Ensure Node deps
foreach ($svc in @("application-service","patient-service")) {
  $svcPath = Join-Path $root $svc
  Write-Host "Installing Node deps for $svc..."
  if (Test-Path (Join-Path $svcPath "package.json")) {
    Push-Location $svcPath
    if (Get-Command npm -ErrorAction SilentlyContinue) {
      npm install
    } else {
      Write-Host "npm not found in PATH. Please install Node.js to build $svc or run npm install manually." -ForegroundColor Yellow
    }
    Pop-Location
  } else {
    Write-Host "No package.json found for $svc, skipping npm install." -ForegroundColor Yellow
  }
}

# 3) Build docker images
$images = @(
  @{ name = 'application-service'; path = 'application-service'; port = 3001 },
  @{ name = 'patient-service'; path = 'patient-service'; port = 3000 },
  @{ name = 'order-service'; path = 'order-service'; port = 8080 }
)

foreach ($img in $images) {
  $name = $img.name
  $path = Join-Path $root $img.path
  $repo = if ($Project) { "$Registry/$Project/$name" } else { "$Registry/$name" }
  $tagFull = "$repo:$Tag"

  Write-Host "Building Docker image for $name -> $tagFull"
  docker build -t $tagFull $path

  if ($Push) {
    Write-Host "Pushing $tagFull"
    docker push $tagFull
  }
}

Write-Host "Done. Check images with 'docker images' or registry to confirm."