param (
    [Parameter(Mandatory=$true)][string]$prefix,
    [string]$namespace = "identity",
    [string]$env,
    [string]$m = "$HOME\Workspace\port-mapping.csv"
)

# --- Step 0: Azure environment ---
$env:AZURE_CONFIG_DIR = "$HOME\.azure-bp"
Write-Host "🏦 Azure environment switched to Banco Pichincha (AZURE_CONFIG_DIR=$env:AZURE_CONFIG_DIR)"

# --- Step 1: Handle Kubernetes context switching ---
if ($env) {
    switch ($env) {
        "dev"  { $context = "aks-dev-coe-seguridad" }
        "test" { $context = "aks-test-coe-seguridad" }
        "prod" { $context = "aks-prod-coe-seguridad" }
        default {
            Write-Error "❌ Invalid --env value. Allowed: dev, test, prod"
            exit 1
        }
    }
    Write-Host "🔄 Switching Kubernetes context to: $context"
    kubectl config use-context $context
}

# --- Step 2: Validate port mapping file ---
if (-not (Test-Path $m)) {
    Write-Error "❌ Port mapping file not found at: $m"
    exit 1
}

# --- Step 3: Find pod ---
Write-Host "🔍 Searching for pod with prefix '$prefix' in namespace '$namespace'..."
$pod = kubectl get pods -n $namespace --no-headers -o custom-columns=":metadata.name" | Where-Object { $_ -like "$prefix-*" } | Select-Object -First 1

if (-not $pod) {
    Write-Error "❌ No pod found with prefix '$prefix-' in namespace '$namespace'"
    exit 1
}

Write-Host "✅ Found pod: $pod"

# --- Step 4: Extract base name before random suffix ---
$baseName = $pod -replace '-[a-zA-Z0-9]{1,15}$', ''

# --- Step 5: Look up port from CSV ---
$mapping = Import-Csv -Path $m -Header "Name","Port"
$match = $mapping | Where-Object { $_.Name -eq $baseName }

if (-not $match) {
    Write-Error "❌ No mapped port found for pod base name '$baseName' in file '$m'"
    exit 1
}

$localPort = $match.Port
$remotePort = 8080

# --- Step 6: Run port-forward ---
Write-Host "🌐 Port forwarding: localhost:$localPort → $pod:$remotePort (namespace: $namespace)"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "kubectl port-forward -n $namespace pod/$pod $localPort:$remotePort" -WindowStyle Normal
