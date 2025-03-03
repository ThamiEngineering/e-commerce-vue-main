#!/bin/bash

# Script pour scanner les vulnérabilités dans les images Docker avec Trivy
# Usage: ./security-scan.sh [registry_url] [image_tag]

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

REGISTRY_URL=${1:-localhost:5000}
IMAGE_TAG=${2:-latest}

echo -e "${BLUE}== Scan de sécurité des images Docker avec Trivy ==${NC}"
echo -e "${YELLOW}Registry URL: ${REGISTRY_URL}${NC}"
echo -e "${YELLOW}Image Tag: ${IMAGE_TAG}${NC}"

if ! command -v trivy &> /dev/null; then
    echo -e "${RED}Trivy n'est pas installé. Installation...${NC}"
    VERSION=$(curl -s "https://api.github.com/repos/aquasecurity/trivy/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
    echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
    sudo apt-get update
    sudo apt-get install -y trivy
    echo -e "${GREEN}Trivy installé avec succès${NC}"
else
    echo -e "${GREEN}Trivy est déjà installé${NC}"
fi

echo -e "${YELLOW}Scan de l'image ${REGISTRY_URL}/frontend:${IMAGE_TAG}...${NC}"
trivy image --no-progress ${REGISTRY_URL}/frontend:${IMAGE_TAG}

echo -e "${YELLOW}Scan de l'image ${REGISTRY_URL}/auth-service:${IMAGE_TAG}...${NC}"
trivy image --no-progress ${REGISTRY_URL}/auth-service:${IMAGE_TAG}

echo -e "${YELLOW}Scan de l'image ${REGISTRY_URL}/product-service:${IMAGE_TAG}...${NC}"
trivy image --no-progress ${REGISTRY_URL}/product-service:${IMAGE_TAG}

echo -e "${YELLOW}Scan de l'image ${REGISTRY_URL}/order-service:${IMAGE_TAG}...${NC}"
trivy image --no-progress ${REGISTRY_URL}/order-service:${IMAGE_TAG}

echo -e "${GREEN}Scan de sécurité terminé avec succès${NC}"
echo -e "${BLUE}Pour déployer l'application, exécutez:${NC}"
echo -e "${YELLOW}./deploy-swarm.sh ${REGISTRY_URL} ${IMAGE_TAG}${NC}"