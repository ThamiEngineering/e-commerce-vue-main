#!/bin/bash

# Script pour valider le déploiement de l'application
# Usage: ./validate-deployment.sh [base_url]

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

BASE_URL=${1:-http://localhost}/

echo -e "${BLUE}== Validation du déploiement de l'application ==${NC}"
echo -e "${YELLOW}URL de base: ${BASE_URL}${NC}"

test_endpoint() {
  local service=$1
  local endpoint=$2
  local method=${3:-GET}
  local expected_status=${4:-200}
  local payload=$5

  echo -e "${YELLOW}Test du service $service - $method $endpoint${NC}"

  local curl_cmd="curl -s -o /dev/null -w "%{http_code}" -X $method $BASE_URL$endpoint"

  if [ -n "$payload" ]; then
    curl_cmd="$curl_cmd -H "Content-Type: application/json" -d '$payload'"
  fi

  local status=$(eval $curl_cmd)

  if [ "$status" -eq "$expected_status" ]; then
    echo -e "${GREEN}✓ Service $service - $method $endpoint - Status: $status${NC}"
    return 0
  else
    echo -e "${RED}✗ Service $service - $method $endpoint - Status: $status (attendu: $expected_status)${NC}"
    return 1
  fi
}

total_tests=0
passed_tests=0

echo -e "${BLUE}Test du frontend...${NC}"
test_endpoint "Frontend" "/"
((total_tests++))
if [ $? -eq 0 ]; then ((passed_tests++)); fi

echo -e "${BLUE}Test des services backend...${NC}"

test_endpoint "Auth Service" "/api/auth/health"
((total_tests++))
if [ $? -eq 0 ]; then ((passed_tests++)); fi

test_endpoint "Product Service" "/api/products"
((total_tests++))
if [ $? -eq 0 ]; then ((passed_tests++)); fi

test_endpoint "Order Service" "/api/orders" "GET" "401"
((total_tests++))
if [ $? -eq 0 ]; then ((passed_tests++)); fi

echo -e "${BLUE}Test d'inscription...${NC}"
USER_EMAIL="test-$(date +%s)@example.com"
USER_PASSWORD="password123"

REGISTER_RESPONSE=$(curl -s -X POST "$BASE_URL/api/auth/register" \
  -H "Content-Type: application/json" \
  -d "{"email": "$USER_EMAIL", "password": "$USER_PASSWORD"}")

if [[ $REGISTER_RESPONSE == "token" ]]; then
  echo -e "${GREEN}✓ Inscription réussie${NC}"
  ((passed_tests++))
else
  echo -e "${RED}✗ Échec de l'inscription${NC}"
fi
((total_tests++))

TOKEN=$(echo $REGISTER_RESPONSE | grep -o '"token":"[^"]' | sed 's/"token":"//')

if [ -n "$TOKEN" ]; then
  echo -e "${GREEN}✓ Token JWT récupéré${NC}"

  PROFILE_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X GET "$BASE_URL/api/auth/profile" \
    -H "Authorization: Bearer $TOKEN")

  if [ "$PROFILE_STATUS" -eq 200 ]; then
    echo -e "${GREEN}✓ Profil utilisateur accessible${NC}"
    ((passed_tests++))
  else
    echo -e "${RED}✗ Profil utilisateur inaccessible - Status: $PROFILE_STATUS${NC}"
  fi
  ((total_tests++))

PRODUCT_RESPONSE=$(curl -s "$BASE_URL/api/products")
PRODUCT_ID=$(echo $PRODUCT_RESPONSE | grep -o '"_id":"[^"]' | head -1 | sed 's/"_id":"//')

if [ -z "$PRODUCT_ID" ]; then
  echo -e "${RED}✗ Impossible de récupérer un ID de produit valide${NC}"
fi

ORDER_PAYLOAD="{"products":[{"productId":"$PRODUCT_ID","quantity":1}],"shippingAddress":{"street":"123 Test St","city":"Test City","postalCode":"12345"}}"

  ORDER_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/api/orders" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d "$ORDER_PAYLOAD")

  if [ "$ORDER_STATUS" -eq 201 ] || [ "$ORDER_STATUS" -eq 200 ]; then
    echo -e "${GREEN}✓ Création de commande réussie${NC}"
    ((passed_tests++))
  else
    echo -e "${RED}✗ Échec de la création de commande - Status: $ORDER_STATUS${NC}"
  fi
  ((total_tests++))
else
  echo -e "${RED}✗ Impossible de récupérer le token JWT${NC}"
fi

echo -e "${BLUE}== Résumé des tests ==${NC}"
echo -e "Tests passés: $passed_tests/$total_tests"

if [ $passed_tests -eq $total_tests ]; then
  echo -e "${GREEN}Tous les tests ont réussi !${NC}"
  exit 0
else
  echo -e "${YELLOW}Certains tests ont échoué. Vérifiez les logs pour plus de détails.${NC}"
  exit 1
fi