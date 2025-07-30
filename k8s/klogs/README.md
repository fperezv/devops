### 📄 **README.md**

# klogs

A Bash utility to stream and optionally save logs from Kubernetes pods.  
Designed for teams working with Azure Kubernetes Service (AKS) in Banco Pichincha environments.

---

## 🚀 Features

- Initializes Azure environment with `~/.azure-bp`
- Streams logs from all matching pods based on prefix
- Validates that all pod names follow the pattern `<prefix>-<randomID>`
- Optional context switch for `dev`, `test`, `prod`
- Optional log saving with timestamped filenames
- Supports custom Kubernetes namespaces

---

## 🧩 Requirements

- `bash`
- `kubectl` configured and authenticated
- Azure CLI using `AZURE_CONFIG_DIR=~/.azure-bp`

---

## 📦 Installation

```bash
chmod +x klogs
sudo mv klogs /usr/local/bin/klogs
```

---

## ⚙️ Usage

```bash
klogs --prefix=<prefix> [--env=dev|test|prod] [--namespace=<namespace>] [-s]
```

### ✅ Arguments

| Argument      | Required | Description                                                               |
| ------------- | -------- | ------------------------------------------------------------------------- |
| `--prefix`    | ✅ Yes    | Pod name prefix (everything before the random ID)                         |
| `--env`       | ❌ No     | Cluster context: `dev`, `test`, `prod`                                    |
| `--namespace` | ❌ No     | Kubernetes namespace (default: `identity`)                                |
| `-s`          | ❌ No     | Save logs to file in `~/Workspace/logs/`, while also printing to terminal |

---

## 📝 Examples

```bash
# Stream logs from pods with prefix "party-authentication"
klogs --prefix=party-authentication

# Stream + save logs for test environment
klogs --prefix=auth-core --env=test -s

# Specify a different namespace
klogs --prefix=user-service --namespace=payments --env=prod -s
```

---

## 📁 Log File Format

If `-s` is used, logs are saved to:

```
~/Workspace/logs/<pod-name>-<env>-<ddMMyyyyHHmmss>.log
```

Example:

```
~/Workspace/logs/party-authentication-test-30072025174012.log
```

---

## 🔐 Notes

* Kubernetes contexts expected:
  
  * `dev` → `aks-dev-coe-seguridad`
  * `test` → `aks-test-coe-seguridad`
  * `prod` → `aks-prod-coe-seguridad`

* Azure config is expected at: `~/.azure-bp`


