.PHONY: help dev clean

# Default target (runs when you just type 'make')
help:
	@echo "🤵 WayStone - Makefile"
	@echo "========================================"
	@echo ""
	@echo "Available commands:"
	@echo "  help         - Show this help message"
	@echo "  check-tools  - Validate tooling is installed"
	@echo "  dev          - Bring up podman containers of all infra and dev services."	
	@echo "  infra-up     - Bring up containerized versions of scaffolding services"
	@echo "  services-dev - Bring up containerized versions of all services."
	@echo "  up, down     - Up and Down Podman network"
	@echo "  logs         - podman logs"
	@echo "  clean        - brings down the podman network and prunes"
	@echo "  grpc-all     - Generates proto files for all grpc connections"
	@echo "  grpc-url     - Generates proto files for the url grpc server"
	@echo ""

# Check if required tools are installed
check-tools:
	@echo "🔍 Checking required tools..."
	@echo ""
	@which go >/dev/null && echo "✅ Go is installed: $(shell go version)" || echo "❌ Go is not installed"
	@which podman >/dev/null && echo "✅ Podman is installed: $(shell podman --version)" || echo "❌ Podman is not installed"
	@which git >/dev/null && echo "✅ Git is installed: $(shell git --version)" || echo "❌ Git is not installed"
	@which curl >/dev/null && echo "✅ Curl is installed" || echo "❌ Curl is not installed"
	@which protoc >/dev/null && echo "✅ Protobuf is installed" || echo "❌ Protobuf is not installed"
	@echo ""
	@echo "📋 Tool check complete!"


dev: infra-up services-dev
	@echo "🗿 Starting Waystone with Podman"
	@echo "Services: http://localhost:8080"
	@echo "Monitoring: http://localhost:3000"

services-dev:
	podman compose -f podman/podman-compose.yml --env-file .env up -d api-gateway url-service

infra-up:
	podman compose -f podman/podman-compose.yml --env-file .env up -d postgres redis prometheus grafana rabbitmq

clean:
	podman compose -f   podman/podman-compose.yml down -v
	podman system prune -f

up:
	podman compose -f podman/podman-compose.yml up --build -d

down:
	podman compose -f podman/podman-compose.yml down -d	

logs:
	podman compose -f podman/podman-compose.yml logs -f

# Proto

grpc-all: grpc-url

grpc-url:
# For api-gateway
  protoc --go_out=services/api-gateway --go-grpc_out=services/api-gateway proto/url/url_service.proto

# For url-service  
  protoc --go_out=services/url --go-grpc_out=services/url proto/url/url_service.proto
