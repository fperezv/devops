### 📄 README.md

# kport

A Bash utility to **port-forward to a Kubernetes pod** based on a name prefix and mapped port definition.

Designed for developers working with AKS clusters at **Banco Pichincha**, where services expose port `8080` internally but require dynamic external port mapping.

---

## 🚀 Features

- Initializes Azure CLI environment (`~/.azure-bp`)
- Finds the **first pod** matching a given `--prefix`
- Uses the base name of the pod (before the random suffix) to look up an external port
- Supports:
  - Context switching via `--env=dev|test|prod`
  - Custom Kubernetes namespace (`--namespace`)
  - Custom mapping file with `-m` argument
- Executes `kubectl port-forward` from mapped port → pod port `8080`

---

## 📁 Port Mapping Format

Default file:  

```bash
~/Workspace/port-mapping.csv
```

Format (CSV):

```
pod-name,external-port
```

Example:

```csv
deployment-idt-msa-validation,8086
deployment-idt-msa-sp-paut-customer-contact,8087
```

---

## 🧩 Requirements

* Bash (`/bin/bash`)
* `kubectl` installed and authenticated
* AKS context access (`kubectl config use-context ...`)
* Azure CLI config directory at `~/.azure-bp`

---

## ⚙️ Usage

```bash
kport --prefix=<prefix> [--env=dev|test|prod] [--namespace=<namespace>] [-m <mapping-file>]
```

### ✅ Arguments

| Argument      | Required | Description                                                       |
| ------------- | -------- | ----------------------------------------------------------------- |
| `--prefix`    | ✅ Yes    | Pod prefix (e.g. `deployment-idt-msa-validation`)                 |
| `--env`       | ❌ No     | Environment context: `dev`, `test`, or `prod`                     |
| `--namespace` | ❌ No     | Kubernetes namespace (default: `identity`)                        |
| `-m <file>`   | ❌ No     | Custom CSV mapping file (default: `~/Workspace/port-mapping.csv`) |

---

## 📝 Examples

```bash
# Default namespace and default mapping file
kport --prefix=deployment-idt-msa-validation

# Custom mapping file
kport --prefix=customer-auth -m ./my-custom-map.csv

# Custom namespace
kport --prefix=customer-auth --namespace=payments

# With environment context switch
kport --prefix=customer-auth --env=prod
```

---

## 🔐 Azure Context Switching

When `--env` is provided, `kport` switches your current Kubernetes context:

| `--env` Value | AKS Context Name         |
| ------------- | ------------------------ |
| `dev`         | `aks-dev-coe-seguridad`  |
| `test`        | `aks-test-coe-seguridad` |
| `prod`        | `aks-prod-coe-seguridad` |

---

## 🌐 What It Does

For a matching pod:

```
deployment-idt-msa-validation-84d66cfd7bmxz
```

With this CSV:

```
deployment-idt-msa-validation,8086
```

Executes:

```bash
kubectl port-forward -n identity pod/deployment-idt-msa-validation-84d66cfd7bmxz 8086:8080
```
