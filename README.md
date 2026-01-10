# Cisco ACI Automation with Docker & Ansible 🚀

Este proyecto implementa una metodología de **Infraestructura como Código (IaC)** para gestionar Cisco ACI. Utiliza **Docker** para garantizar un entorno de ejecución consistente y **Ansible** para desplegar inquilinos (Tenants), redes (VRFs/BDs) y conectividad física (Static Paths) de forma automatizada.

## 📁 Estructura del Proyecto

```text
aci-automation/
├── Dockerfile               # Definición del entorno (Python, Ansible, colecciones)
├── ansible.cfg              # Configuración global de Ansible
├── inventory.yaml           # Datos de acceso al APIC
├── vars/
│   └── network_model.yaml   # Fuente de verdad (Variables de red)
└── playbooks/
    └── deploy_infra.yaml    # Lógica de despliegue

🛠️ Requisitos Previos

    Docker instalado en tu estación de trabajo.

    Acceso HTTPS (puerto 443) desde tu máquina hacia el Cisco APIC.

    Credenciales de administrador para el APIC.

🚀 Guía de Uso Rápido
1. Construir el Entorno

Ejecuta este comando para crear la imagen de Docker con todas las dependencias necesarias:
Bash

docker build -t aci-ansible .

2. Configurar las Variables

Edita el archivo vars/network_model.yaml para definir tu topología. Puedes configurar:

    Tenants, VRFs y Bridge Domains (incluyendo subnets y políticas L2).

    Application Profiles y EPGs.

    Dominios (Físicos y VMM).

    Static Paths (Puertos individuales, Port-Channels y vPCs).

3. Ejecutar el Despliegue

Lanza el playbook utilizando el contenedor:
Bash

docker run --rm -it -v $(pwd):/ansible aci-ansible ansible-playbook playbooks/deploy_infra.yaml

⚙️ Configuración Técnica
Modelo de Objetos ACI

El proyecto sigue la jerarquía lógica de Cisco ACI para asegurar que los objetos se creen en el orden correcto:
Características Principales

    Idempotencia: Si ejecutas el script dos veces sin cambios en el YAML, Ansible no realizará ninguna acción.

    Abstracción: Los Static Paths detectan automáticamente si el destino es un puerto físico o un vPC basándose en las variables definidas.

    Seguridad: El contenedor utiliza requests con validación de certificados configurable.

📝 Notas de Implementación

    Modo de Interfaz: Por defecto, los puertos se configuran como regular (Trunk). Cambia a untagged para puertos de acceso tradicionales.

    L2 Optimization: El Bridge Domain está preconfigurado para usar Hardware Proxy (unicast-routing activo) para minimizar el broadcast en el fabric.


### 4. Revertir Cambios (Rollback)
Si necesitas eliminar toda la configuración definida en el archivo de variables:

```bash
docker run --rm -it -v $(pwd):/ansible aci-ansible ansible-playbook playbooks/rollback_infra.yaml

3. Flujo Final del Ciclo de Vida

    Modificar: Editas network_model.yaml.

    Validar: (Opcional) Usas --check en el comando de Docker para ver qué pasaría sin aplicar.

    Desplegar: Corres deploy_infra.yaml.

    Limpiar: Corres rollback_infra.yaml si ya no necesitas el entorno.

Nota Pro: En ACI, al borrar un Tenant con state: absent, el APIC borra automáticamente todos los objetos hijos 
(VRFs, BDs, APs, EPGs). Por eso el playbook de rollback es mucho más corto.
