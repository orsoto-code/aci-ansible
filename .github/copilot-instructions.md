# Copilot Instructions — ACI Automation (Docker + Ansible)

This file collects the minimal, high-value guidance an AI coding agent needs to be immediately productive in this repository.

1. Big picture
- Purpose: orchestrate Cisco ACI objects (Tenants, VRFs, BDs, APs, EPGs, Static Paths) via Ansible and the official `cisco.aci` collection.
- Runtime: tooling runs inside a Docker image (`Dockerfile`) that installs Python, Ansible and the `cisco.aci` collection. Typical image name used: `aci-ansible`.

2. Key files & entry points
- Playbooks: `playbooks/deploy_infra.yaml` (deploy) and `playbooks/rollback_infra.yaml` (destroy). These are the canonical flows to apply or remove configuration.
- Inventory: `inventory.yaml` defines host `apic01` and required connection variables (`ansible_host`, `ansible_user`, `ansible_password`, `ansible_connection: local`).
- Network model: repository source-of-truth is under `var/network_model.yaml` (defines `aci_infrastructure.tenants`). Note: playbooks expect `../vars/network_model.yaml` — there is a `var` vs `vars` mismatch in the repo that should be verified before running.
- Ansible config: `ansible.cfg` sets `inventory = ./inventory.yaml` and `host_key_checking = False`.
- Docker: `docker build -t aci-ansible .` then run with `docker run --rm -it -v $(pwd):/ansible aci-ansible ansible-playbook playbooks/deploy_infra.yaml`.

3. Project-specific conventions & patterns
- Directory mismatch: playbooks use `vars/network_model.yaml` relative path; actual file is `var/network_model.yaml`. Confirm which directory is canonical before changing playbooks or CI.
- Inventory connection: machines use `ansible_connection: local` — the playbooks call the APIC API from the local execution environment, not via SSH to the APIC.
- Credentials: `inventory.yaml` carries `ansible_user` and `ansible_password`. Look here when searching for authentication assumptions.
- Module usage: the playbooks consistently pass `hostname: {{ ansible_host }}`, `username`, `password`, and `validate_certs: no` to `cisco.aci.*` modules. Expect certificate validation to be disabled by default in this repo.

4. Template & looping idioms (concrete examples)
- Building flat lists with Jinja: playbooks construct lists like `epg_list` and `path_list` using nested loops and `set _ = ...append(...)`. Follow that pattern when adding similar aggregated loops.
- Subelements: use `{{ aci_infrastructure.tenants | subelements('vrfs') }}` for two-level loops (see `aci_vrf` task).
- Interface type detection: static path entries may set `port`, `port_channel`, or `vpc`; playbooks compute `interface_type` via a Jinja conditional:

```jinja
interface_type: "{{ 'vpc' if item.vpc is defined else ('port-channel' if item.port_channel is defined else 'switch-port') }}"
```

5. Recommended safety checks for changes
- Before running any playbook, confirm the inventory credentials and `ansible_host` point to the intended APIC.
- To preview changes, run the same `docker run` invocation but append `--check` to `ansible-playbook` inside the container.

6. CI / automation notes
- `.github/workflows/main.yml` exists but is empty; no CI is configured. If adding CI, ensure the Docker build and `ansible-galaxy collection install cisco.aci` run in workflow steps.

7. What the agent should not change automatically
- Do not overwrite `inventory.yaml` credentials or commit real passwords.
- Do not unilaterally rename `var/` → `vars/` without confirmation; document the change and update playbook paths accordingly.

8. If you add code or tasks, follow these quick checks
- Validate YAML syntax for modified playbooks and `var/network_model.yaml`.
- Keep Ansible module calls consistent: always pass `hostname`, `username`, `password`, and `validate_certs` as shown in existing tasks.

If anything here is unclear or you want additional examples (e.g., a safe CI job or a helper script to run playbooks locally), tell me which area to expand. 
