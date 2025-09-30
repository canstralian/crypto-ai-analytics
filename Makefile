.PHONY: help dev-setup dev-start dev-stop build test lint clean deploy-staging deploy-prod

# Default target
help: ## Show this help message
	@echo "Crypto-AI Analytics - Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Development commands
dev-setup: ## Set up development environment
	@echo "Setting up development environment..."
	@if [ ! -f .env ]; then cp .env.example .env; fi
	@docker-compose -f docker-compose.dev.yml pull
	@if [ -d backend ]; then cd backend && pip install -r requirements-dev.txt; fi
	@if [ -d frontend ]; then cd frontend && npm install; fi
	@echo "Development environment setup complete!"

dev-start: ## Start development services
	@echo "Starting development services..."
	@docker-compose -f docker-compose.dev.yml up -d postgres redis kafka
	@echo "Core services started. Use 'make dev-backend' and 'make dev-frontend' to start applications."

dev-backend: ## Start backend development server
	@echo "Starting backend development server..."
	@cd backend && uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

dev-frontend: ## Start frontend development server
	@echo "Starting frontend development server..."
	@cd frontend && npm run dev

dev-stop: ## Stop development services
	@echo "Stopping development services..."
	@docker-compose -f docker-compose.dev.yml down

dev-logs: ## Show development service logs
	@docker-compose -f docker-compose.dev.yml logs -f

# Database commands
db-migrate: ## Run database migrations
	@echo "Running database migrations..."
	@cd backend && alembic upgrade head

db-reset: ## Reset database (WARNING: This will delete all data)
	@echo "Resetting database..."
	@docker-compose -f docker-compose.dev.yml down -v
	@docker-compose -f docker-compose.dev.yml up -d postgres
	@sleep 5
	@cd backend && alembic upgrade head

db-seed: ## Seed database with sample data
	@echo "Seeding database..."
	@cd backend && python scripts/seed_data.py

# Testing commands
test: ## Run all tests
	@echo "Running all tests..."
	@make test-backend
	@make test-frontend
	@make test-integration

test-backend: ## Run backend tests
	@echo "Running backend tests..."
	@cd backend && python -m pytest -v --cov=app --cov-report=html

test-frontend: ## Run frontend tests
	@echo "Running frontend tests..."
	@cd frontend && npm run test

test-integration: ## Run integration tests
	@echo "Running integration tests..."
	@docker-compose -f docker-compose.test.yml up -d
	@sleep 30
	@python -m pytest tests/integration/ -v
	@docker-compose -f docker-compose.test.yml down

test-e2e: ## Run end-to-end tests
	@echo "Running E2E tests..."
	@cd frontend && npm run test:e2e

# Code quality commands
lint: ## Run linting for all code
	@echo "Running linting..."
	@make lint-backend
	@make lint-frontend

lint-backend: ## Run backend linting
	@echo "Linting backend code..."
	@cd backend && flake8 app/ tests/
	@cd backend && black --check app/ tests/
	@cd backend && isort --check-only app/ tests/

lint-frontend: ## Run frontend linting
	@echo "Linting frontend code..."
	@cd frontend && npm run lint

format: ## Format all code
	@echo "Formatting code..."
	@make format-backend
	@make format-frontend

format-backend: ## Format backend code
	@echo "Formatting backend code..."
	@cd backend && black app/ tests/
	@cd backend && isort app/ tests/

format-frontend: ## Format frontend code
	@echo "Formatting frontend code..."
	@cd frontend && npm run format

type-check: ## Run type checking
	@echo "Running type checks..."
	@cd backend && mypy app/
	@cd frontend && npm run type-check

security-scan: ## Run security scanning
	@echo "Running security scans..."
	@cd backend && bandit -r app/
	@cd frontend && npm audit

# Build commands
build: ## Build all Docker images
	@echo "Building Docker images..."
	@docker-compose build

build-backend: ## Build backend Docker image
	@echo "Building backend Docker image..."
	@docker build -t crypto-ai-analytics/backend backend/

build-frontend: ## Build frontend Docker image
	@echo "Building frontend Docker image..."
	@docker build -t crypto-ai-analytics/frontend frontend/

# ML commands
train-models: ## Train ML models
	@echo "Training ML models..."
	@cd ml && python train_all_models.py

evaluate-models: ## Evaluate ML models
	@echo "Evaluating ML models..."
	@cd ml && python evaluate_models.py

# Infrastructure commands
infra-plan: ## Plan Terraform infrastructure changes
	@echo "Planning infrastructure changes..."
	@cd infra/terraform && terraform plan

infra-apply: ## Apply Terraform infrastructure changes
	@echo "Applying infrastructure changes..."
	@cd infra/terraform && terraform apply

infra-destroy: ## Destroy Terraform infrastructure (WARNING: This will delete all resources)
	@echo "Destroying infrastructure..."
	@cd infra/terraform && terraform destroy

# Deployment commands
deploy-staging: ## Deploy to staging environment
	@echo "Deploying to staging..."
	@./scripts/deploy.sh staging

deploy-prod: ## Deploy to production environment
	@echo "Deploying to production..."
	@./scripts/deploy.sh production

# Monitoring commands
logs-backend: ## Show backend logs
	@kubectl logs -f deployment/backend-deployment

logs-frontend: ## Show frontend logs
	@kubectl logs -f deployment/frontend-deployment

metrics: ## Open Grafana dashboard
	@echo "Opening Grafana dashboard..."
	@kubectl port-forward service/grafana 3000:3000 &
	@open http://localhost:3000

# Utility commands
clean: ## Clean up temporary files and caches
	@echo "Cleaning up..."
	@find . -type f -name "*.pyc" -delete
	@find . -type d -name "__pycache__" -delete
	@find . -type d -name "*.egg-info" -exec rm -rf {} +
	@find . -type d -name ".pytest_cache" -exec rm -rf {} +
	@find . -type d -name "node_modules" -exec rm -rf {} +
	@docker system prune -f

docs: ## Generate and serve documentation
	@echo "Generating documentation..."
	@cd docs && mkdocs serve

install: ## Install project dependencies
	@echo "Installing dependencies..."
	@if [ -d backend ]; then cd backend && pip install -r requirements.txt; fi
	@if [ -d frontend ]; then cd frontend && npm install; fi

update-deps: ## Update project dependencies
	@echo "Updating dependencies..."
	@if [ -d backend ]; then cd backend && pip-compile --upgrade requirements.in; fi
	@if [ -d frontend ]; then cd frontend && npm update; fi

backup-db: ## Backup database
	@echo "Backing up database..."
	@./scripts/backup_db.sh

restore-db: ## Restore database from backup
	@echo "Restoring database..."
	@./scripts/restore_db.sh