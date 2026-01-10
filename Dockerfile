FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Dependencias básicas
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Librerías de Python para ACI
RUN pip install --no-cache-dir ansible requests urllib3 jmespath

# Colección oficial de Cisco ACI
RUN ansible-galaxy collection install cisco.aci

WORKDIR /ansible
