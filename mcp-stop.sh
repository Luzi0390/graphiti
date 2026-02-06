#!/bin/bash
# Graphiti MCP Server 停止脚本
# 用法: ./mcp-stop.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MCP_DIR="$SCRIPT_DIR/mcp_server"
COMPOSE_FILE="docker/docker-compose-gemini-neo4j.yml"

echo "=========================================="
echo "  Graphiti MCP Server 停止"
echo "=========================================="

cd "$MCP_DIR"

echo "🛑 停止服务..."
docker compose --env-file .env -f "$COMPOSE_FILE" down

echo ""
echo "✅ 服务已停止"
