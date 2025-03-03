#!/bin/bash

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

    if [[ "$OSTYPE" == "darwin"* ]]; then
        if ! command -v brew &> /dev/null; then
            echo -e "${RED}Homebrew n'est pas installé. Installation...${NC}"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        brew install trivy
        echo -e "${GREEN}Trivy installé avec succès sur macOS${NC}"
    elif [[ -f /etc/debian_version ]]; then
        sudo apt update
        sudo apt install -y wget gnupg lsb-release
        wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo tee /etc/apt/keyrings/trivy.asc
        echo "deb [signed-by=/etc/apt/keyrings/trivy.asc] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/trivy.list
        sudo apt update
        sudo apt install -y trivy
        echo -e "${GREEN}Trivy installé avec succès sur Linux${NC}"
    else
        echo -e "${RED}Système non pris en charge pour l'installation automatique de Trivy.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}Trivy est déjà installé${NC}"
fi

for service in frontend auth-service product-service order-service; do
    echo -e "${YELLOW}Scan de l'image ${REGISTRY_URL}/${service}:${IMAGE_TAG}...${NC}"
    trivy image --no-progress ${REGISTRY_URL}/${service}:${IMAGE_TAG}
done

echo -e "${GREEN}Scan de sécurité terminé avec succès${NC}"
echo -e "${BLUE}Pour déployer l'application, exécutez:${NC}"
echo -e "${YELLOW}./deploy-swarm.sh ${REGISTRY_URL} ${IMAGE_TAG}${NC}"
