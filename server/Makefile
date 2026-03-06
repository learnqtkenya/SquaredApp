.PHONY: up down build run logs deploy patch

APP_NAME = squared-store
BUILD_DIR = bin
DEPLOY_HOST = proms@ssh-proms.alwaysdata.net
DEPLOY_DIR = ~/squared-store

up:
	docker compose up --build -d

down:
	docker compose down

build:
	GOOS=linux GOARCH=amd64 go build -o $(BUILD_DIR)/$(APP_NAME) ./cmd/server

run:
	go build -o $(BUILD_DIR)/$(APP_NAME) ./cmd/server && ./$(BUILD_DIR)/$(APP_NAME)

logs:
	docker compose logs -f squared-store

deploy: build
	@echo "Deploying $(APP_NAME) to production server..."
	@mkdir -p ~/.ssh/tmp
	@ssh -o ControlMaster=yes -o ControlPath=~/.ssh/tmp/%r@%h:%p -o ControlPersist=10m -f $(DEPLOY_HOST) 'true'
	@echo "Creating deployment directory..."
	@ssh -o ControlMaster=no -o ControlPath=~/.ssh/tmp/%r@%h:%p $(DEPLOY_HOST) 'mkdir -p $(DEPLOY_DIR)'
	@echo "Copying binary..."
	@scp -o ControlMaster=no -o ControlPath=~/.ssh/tmp/%r@%h:%p $(BUILD_DIR)/$(APP_NAME) $(DEPLOY_HOST):$(DEPLOY_DIR)/
	@echo "Copying environment configuration..."
	@scp -o ControlMaster=no -o ControlPath=~/.ssh/tmp/%r@%h:%p .env.deploy $(DEPLOY_HOST):$(DEPLOY_DIR)/.env
	@echo "Copying database migrations..."
	@scp -r -o ControlMaster=no -o ControlPath=~/.ssh/tmp/%r@%h:%p migrations/ $(DEPLOY_HOST):$(DEPLOY_DIR)/
	@echo "Closing SSH connection..."
	@ssh -o ControlPath=~/.ssh/tmp/%r@%h:%p -O exit $(DEPLOY_HOST) 2>/dev/null || true
	@echo "Deployment completed successfully!"
	@echo "To run on server: ssh $(DEPLOY_HOST) 'cd $(DEPLOY_DIR) && ./$(APP_NAME)'"

patch: build
	@echo "Deploying binary only..."
	@mkdir -p ~/.ssh/tmp
	@ssh -o ControlMaster=yes -o ControlPath=~/.ssh/tmp/%r@%h:%p -o ControlPersist=10m -f $(DEPLOY_HOST) 'true'
	@scp -o ControlMaster=no -o ControlPath=~/.ssh/tmp/%r@%h:%p $(BUILD_DIR)/$(APP_NAME) $(DEPLOY_HOST):$(DEPLOY_DIR)/
	@ssh -o ControlPath=~/.ssh/tmp/%r@%h:%p -O exit $(DEPLOY_HOST) 2>/dev/null || true
	@echo "Patch deployed successfully!"
