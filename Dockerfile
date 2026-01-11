FROM python:3.11-slim

# Instalamos dependencias del sistema necesarias
RUN apt-get update && apt-get install -y \
    gcc \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Instalamos Ansible y las librerías que requiere la API de ACI
RUN pip install --no-cache-dir ansible requests urllib3 jmespath

# Instalamos la colección de Cisco ACI desde Ansible Galaxy
RUN ansible-galaxy collection install cisco.aci

WORKDIR /ansible
