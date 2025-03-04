# E-Commerce Microservices

Application e-commerce basée sur une architecture microservices avec Docker et Docker Swarm.

## Architecture du projet

Cette application utilise une architecture microservices déployée avec Docker:

- **Frontend**: Application Vue.js
- **Backend**:
  - **Service d'authentification**: Gestion des utilisateurs et de l'authentification (JWT)
  - **Service de produits**: Gestion des produits et du panier
  - **Service de commandes**: Gestion des commandes
- **Base de données**: MongoDB

## Prérequis

- Docker et Docker Compose
- Docker Swarm (pour la production)
- Git

## Structure du projet

```
.
├── docker-compose.prod.yml     # Fichier docker-compose pour la production
├── docker-compose.yml          # Fichier docker-compose pour le développement
├── frontend/                   # Application frontend Vue.js
├── services/                   # Services backend
│   ├── auth-service/           # Service d'authentification
│   ├── product-service/        # Service de produits et panier
│   └── order-service/          # Service de commandes
└── scripts/                    # Scripts utilitaires
    ├── deploy-swarm.sh         # Script de déploiement avec Docker Swarm
    ├── setup-registry.sh       # Script pour configurer une registry Docker privée
    ├── security-scan.sh        # Script pour scanner les images avec Trivy
    ├── init-products.sh        # Script pour initialiser les produits
    └── run-tests.sh            # Script pour exécuter les tests
```

## Démarrage rapide

### Environnement de développement

1. Cloner le dépôt :
   ```bash
   git clone <URL_DU_DÉPÔT>
   cd <NOM_DU_PROJET>
   ```

2. Démarrer l'application avec Docker Compose :
   ```bash
   docker-compose up --build
   ```

3. Initialiser les données des produits :
   ```bash
   ./scripts/init-products.sh
   ```

4. Accéder à l'application :
   - Frontend : http://localhost:8080
   - API Auth Service : http://localhost:3001
   - API Product Service : http://localhost:3000
   - API Order Service : http://localhost:3002

### Environnement de production avec Docker Swarm

1. Configurer une registry Docker privée (si nécessaire) :
   ```bash
   ./scripts/setup-registry.sh
   ```

2. Scanner les images Docker pour les vulnérabilités :
   ```bash
   ./scripts/security-scan.sh localhost:5001 v1.0.0
   ```

3. Déployer l'application avec Docker Swarm :
   ```bash
   ./scripts/deploy-swarm.sh localhost:5001 v1.0.0
   ```

4. Vérifier l'état des services :
   ```bash
   docker stack services e-commerce
   ```

## Caractéristiques techniques

- **Multi-stage builds**: Optimisation des images Docker
- **Containers sécurisés**: Exécution avec un utilisateur non-root
- **Haute disponibilité**: Réplication des services avec Docker Swarm
- **Health checks**: Surveillance de l'état des services
- **Logs centralisés**: Configuration des logs
- **Secrets sécurisés**: Gestion des variables d'environnement

## Endpoints API

### Auth Service
- `POST /api/auth/register` : Inscription
- `POST /api/auth/login` : Connexion
- `GET /api/auth/profile` : Profil utilisateur

### Product Service
- `GET /api/products` : Liste des produits
- `GET /api/products/:id` : Détails d'un produit
- `POST /api/cart/add` : Ajouter au panier
- `DELETE /api/cart/remove/:productId` : Supprimer du panier
- `GET /api/cart` : Consulter le panier

### Order Service
- `POST /api/orders` : Créer une commande
- `GET /api/orders` : Liste des commandes
- `GET /api/orders/:id` : Détails d'une commande

## Bonnes pratiques implémentées

- **Sécurité**: Utilisateurs non-root, variables d'environnement sécurisées
- **Optimisation**: Multi-stage builds, images légères
- **Haute disponibilité**: Réplication des services
- **Monitoring**: Health checks
- **Logging**: Configuration des logs

## Auteurs

- MARZAK Thami
- RONDEAU Allan

