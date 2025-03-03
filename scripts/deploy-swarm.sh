#!/bin/bash

# Script pour déployer l'application avec Docker Swarm
# Usage: ./deploy-swarm.sh [registry_url] [image_tag]

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

REGISTRY_URL=${1:-localhost:5000}
IMAGE_TAG=${2:-latest}
JWT_SECRET=${JWT_SECRET:-efrei_super_pass}
MONGO_ROOT_PASSWORD=${MONGO_ROOT_PASSWORD:-example}

echo -e "${BLUE}== Déploiement de l'application e-commerce avec Docker Swarm ==${NC}"
echo -e "${YELLOW}Registry URL: ${REGISTRY_URL}${NC}"
echo -e "${YELLOW}Image Tag: ${IMAGE_TAG}${NC}"

if ! docker info | grep -q "Swarm: active"; then
    echo -e "${YELLOW}Initialisation de Docker Swarm...${NC}"
    docker swarm init --advertise-addr $(hostname -i | awk '{print $1}')
    echo -e "${GREEN}Docker Swarm initialisé${NC}"
else
    echo -e "${GREEN}Docker Swarm est déjà initialisé${NC}"
fi

echo -e "${YELLOW}Construction des images Docker...${NC}"

echo -e "${BLUE}Construction de l'image frontend...${NC}"
docker build -t ${REGISTRY_URL}/frontend:${IMAGE_TAG} -f frontend/Dockerfile ./frontend

echo -e "${BLUE}Construction de l'image auth-service...${NC}"
docker build -t ${REGISTRY_URL}/auth-service:${IMAGE_TAG} -f services/auth-service/Dockerfile ./services/auth-service

echo -e "${BLUE}Construction de l'image product-service...${NC}"
docker build -t ${REGISTRY_URL}/product-service:${IMAGE_TAG} -f services/product-service/Dockerfile ./services/product-service

echo -e "${BLUE}Construction de l'image order-service...${NC}"
docker build -t ${REGISTRY_URL}/order-service:${IMAGE_TAG} -f services/order-service/Dockerfile ./services/order-service

if [ "$REGISTRY_URL" != "localhost:5000" ]; then
    echo -e "${YELLOW}Envoi des images vers le registry ${REGISTRY_URL}...${NC}"
    docker push ${REGISTRY_URL}/frontend:${IMAGE_TAG}
    docker push ${REGISTRY_URL}/auth-service:${IMAGE_TAG}
    docker push ${REGISTRY_URL}/product-service:${IMAGE_TAG}
    docker push ${REGISTRY_URL}/order-service:${IMAGE_TAG}
fi

echo -e "${YELLOW}Déploiement de la stack avec Docker Swarm...${NC}"
REGISTRY_URL=${REGISTRY_URL} IMAGE_TAG=${IMAGE_TAG} JWT_SECRET=${JWT_SECRET} MONGO_ROOT_PASSWORD=${MONGO_ROOT_PASSWORD} \
docker stack deploy -c docker-compose.prod.yml e-commerce

echo -e "${GREEN}Déploiement terminé${NC}"
echo -e "${BLUE}Pour vérifier l'état des services:${NC} docker stack services e-commerce"
echo -e "${BLUE}Pour retirer la stack:${NC} docker stack rm e-commerce"