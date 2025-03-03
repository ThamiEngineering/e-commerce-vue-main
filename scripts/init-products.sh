#!/bin/bash

# Script pour initialiser les produits dans la base de données
# Usage: ./init-products.sh [product_service_url]

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

PRODUCT_SERVICE_URL=${1:-http://localhost:3000}
TOKEN="efrei_super_pass"

echo -e "${BLUE}== Initialisation des produits dans la base de données ==${NC}"
echo -e "${YELLOW}URL du service produit: ${PRODUCT_SERVICE_URL}${NC}"

echo -e "${YELLOW}Attente que le service produit soit disponible...${NC}"
max_attempts=30
attempt=0

while [ $attempt -lt $max_attempts ]; do
  if curl -s --head --request GET $PRODUCT_SERVICE_URL/api/health | grep "200" > /dev/null; then
    echo -e "${GREEN}Service produit disponible${NC}"
    break
  fi
  attempt=$((attempt+1))
  echo -e "${YELLOW}Tentative $attempt/$max_attempts - Service indisponible, nouvelle tentative dans 5 secondes...${NC}"
  sleep 5
done

if [ $attempt -eq $max_attempts ]; then
  echo -e "${RED}Le service produit n'est pas disponible après $max_attempts tentatives${NC}"
  exit 1
fi

create_product() {
  local name=$1
  local price=$2
  local description=$3
  local stock=$4

  echo -e "${YELLOW}Création du produit: $name${NC}"
  
  curl -s -X POST "$PRODUCT_SERVICE_URL/api/products" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d "{
      \"name\": \"$name\",
      \"price\": $price,
      \"description\": \"$description\",
      \"stock\": $stock
    }"
  
  echo -e "${GREEN}Produit créé: $name${NC}"
}

echo -e "${YELLOW}Vérification si des produits existent déjà...${NC}"
EXISTING_PRODUCTS=$(curl -s -X GET "$PRODUCT_SERVICE_URL/api/products")

if [[ $EXISTING_PRODUCTS == *"name"* ]]; then
  echo -e "${YELLOW}Des produits existent déjà. Souhaitez-vous les réinitialiser? (y/n)${NC}"
  read -r answer
  if [[ "$answer" != "y" ]]; then
    echo -e "${BLUE}Initialisation annulée${NC}"
    exit 0
  fi
fi

echo -e "${YELLOW}Initialisation des produits...${NC}"

create_product "Smartphone Galaxy S21" 899 "Dernier smartphone Samsung avec appareil photo 108MP" 15
create_product "MacBook Pro M1" 1299 "Ordinateur portable Apple avec puce M1" 10
create_product "PS5" 499 "Console de jeu dernière génération" 5
create_product "Écouteurs AirPods Pro" 249 "Écouteurs sans fil avec réduction de bruit" 20
create_product "Nintendo Switch" 299 "Console de jeu portable" 12
create_product "iPad Air" 599 "Tablette Apple avec écran Retina" 8
create_product "Montre connectée" 199 "Montre intelligente avec suivi d'activité" 25
create_product "Enceinte Bluetooth" 79 "Enceinte portable waterproof" 30

echo -e "${GREEN}Initialisation des produits terminée avec succès${NC}"