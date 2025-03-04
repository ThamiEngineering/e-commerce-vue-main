
#!/bin/bash

# Script pour configurer une registry Docker privée locale
# Usage: ./setup-registry.sh [registry_port]

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

REGISTRY_PORT=${1:-5001}

echo -e "${BLUE}== Configuration d'une registry Docker privée ==${NC}"
echo -e "${YELLOW}Port de la registry: ${REGISTRY_PORT}${NC}"

if docker ps -a | grep -q "registry"; then
    echo -e "${YELLOW}Un conteneur 'registry' existe déjà. Suppression...${NC}"
    docker rm -f registry || true
fi

echo -e "${YELLOW}Création du volume pour la registry...${NC}"
docker volume create registry-data || true

echo -e "${YELLOW}Démarrage de la registry Docker sur le port ${REGISTRY_PORT}...${NC}"
docker run -d \
    --name registry \
    --restart always \
    -p ${REGISTRY_PORT}:5000 \
    -v registry-data:/var/lib/registry \
    registry:2

echo -e "${GREEN}Registry Docker démarrée sur localhost:${REGISTRY_PORT}${NC}"
echo -e "${BLUE}Pour utiliser cette registry avec les scripts de déploiement:${NC}"
echo -e "${YELLOW}./deploy-swarm.sh localhost:${REGISTRY_PORT} v1.0.0${NC}"