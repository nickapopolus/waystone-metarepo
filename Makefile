.PHONY: help dev clean

# Default target (runs when you just type 'make')
help:
	@echo "🤵 WayStone - Makefile"
	@echo "========================================"
	@echo ""
	@echo "Available commands:"
	@echo "  help        - Show this help message"
	@echo "  check-tools - Validate tooling is installed"
	@echo "  dev - Echo a dummy message"
	@echo ""

# Check if required tools are installed
check-tools:
	@echo "🔍 Checking required tools..."
	@echo ""
	@which go >/dev/null && echo "✅ Go is installed: $(shell go version)" || echo "❌ Go is not installed"
	@which podman >/dev/null && echo "✅ Podman is installed: $(shell podman --version)" || echo "❌ Podman is not installed"
	@which git >/dev/null && echo "✅ Git is installed: $(shell git --version)" || echo "❌ Git is not installed"
	@which curl >/dev/null && echo "✅ Curl is installed" || echo "❌ Curl is not installed"
	@echo ""
	@echo "📋 Tool check complete!"


dev: infra-up services-dev
	@echo "🗿 Starting Waystone with Podman"
#	@echo "Services: http://localhost:8080"
	@echo "Monitoring: http://localhost:3000"

services-dev:
	podman compose -f podman/podman-compose.yml --env-file .env up api-gateway

infra-up:
	podman compose -f podman/podman-compose.yml --env-file .env up -d postgres redis prometheus grafana rabbitmq

clean:
	podman compose -f   podman/podman-compose.yml down -v
	podman system prune -f

