.PHONY: install deploy clean test help quickstart

setup:
	@chmod +x scripts/install.sh
	@./scripts/install.sh

deploy:
	@chmod +x scripts/deploy.sh
	@./scripts/deploy.sh

run: setup deploy
	@echo "Access your app at: http://localhost:8000"

test:
	@chmod +x scripts/test.sh
	@./scripts/test.sh

clean:
	@chmod +x scripts/cleanup.sh
	@./scripts/cleanup.sh

help:
	@echo "Available targets:"
	@echo "  install    - Set up Kubernetes cluster"
	@echo "  deploy     - Deploy the application"
	@echo "  quickstart - Install cluster and deploy app"
	@echo "  test       - Run application tests"
	@echo "  clean      - Clean up resources" 
	@echo "  help       - Show this help"