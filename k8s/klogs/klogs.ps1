# klogs.ps1
param (
    [Parameter(Mandatory=$true)][string]$prefix,
    [string]$env,
    [string]$namespace = "identity",
    [switch]$s
)

# --- Step 1: Azure environment ---
$env:AZURE_CONFIG_DIR = "$HOME\.azure-bp"
Write-Host "🏦 Azure environment switched to Banco Pichincha (AZURE_CONFIG_DIR=$env:AZURE_CONFIG_DIR)"

# --- Step 2: Switch Kubernetes context if env is provided ---
switch ($env) {
    "dev"  { $context = "aks-dev-coe-seguridad" }
    "test" { $context = "aks-test-coe-seguridad" }
    "prod" { $context = "aks-prod-coe-seguridad" }
    ""     { $context = $null }
    default {
        Write-Error "❌ Invalid environment: $env. Allowed: dev, test, prod"
        exit 1
    }
}

if ($context) {
    Write-Host "🔄 Switching Kubernetes context to: $context"
    kubectl config use-context $context
}

# --- Step 3: Retrieve pods ---
Write-Host "🔍 Searching for pods in namespace '$namespace' with prefix '$prefix-'..."
$pods = kubectl get pods -n $namespace --no-headers -o custom-columns=":metadata.name" | Where-Object { $_ -like "$prefix-*" }

if (-not $pods) {
    Write-Host "⚠️ No pods found with prefix '$prefix-' in namespace '$namespace'."
    exit 1
}

# --- Step 4: Validate pod name pattern ---
$firstPod = $pods[0]
$baseName = $firstPod -replace '-[a-zA-Z0-9]{1,15}$', ''
$pattern = "^$baseName-[a-zA-Z0-9]{1,15}$"

$allValid = $true
$invalidPods = @()

foreach ($pod in $pods) {
    if ($pod -notmatch $pattern) {
        $invalidPods += $pod
        $allValid = $false
    }
}

if (-not $allValid) {
    Write-Host "❌ Invalid pods found. All pods must match pattern: $pattern"
    $invalidPods | ForEach-Object { Write-Host " - $_" }
    exit 1
}

# --- Step 5: Setup log saving if needed ---
$timestamp = Get-Date -Format "ddMMyyyyHHmmss"
$logDir = "$HOME\Workspace\logs"
New-Item -ItemType Directory -Path $logDir -Force | Out-Null

# --- Step 6: Stream logs ---
Write-Host "📦 Streaming logs..."
foreach ($pod in $pods) {
    Write-Host "📄 Streaming logs for pod: $pod"
    if ($s -and $env) {
        $shortName = $pod -replace '-[a-zA-Z0-9]{1,15}$', ''
        $logPath = Join-Path $logDir "$shortName-$env-$timestamp.log"
        Write-Host "💾 Saving logs to: $logPath"
        Start-Process powershell -ArgumentList "-NoExit", "-Command", "kubectl logs -n $namespace -f $pod | Tee-Object -FilePath '$logPath'" -WindowStyle Normal
    } else {
        Start-Process powershell -ArgumentList "-NoExit", "-Command", "kubectl logs -n $namespace -f $pod" -WindowStyle Normal
    }
}
