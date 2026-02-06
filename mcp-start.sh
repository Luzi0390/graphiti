#!/bin/bash
# Graphiti MCP Server 启动脚本
# 用法: ./mcp-start.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MCP_DIR="$SCRIPT_DIR/mcp_server"
COMPOSE_FILE="docker/docker-compose-gemini-neo4j.yml"

# 设置临时目录，如果 /data/tmp 存在则优先使用，解决 /var 空间不足的问题
if [ -d "/data/tmp" ]; then
    export TMPDIR="/data/tmp"
    export BUILDAH_TMPDIR="/data/tmp"
    echo "📂 使用临时目录: $TMPDIR (解决 /var 空间不足问题)"
fi

echo "=========================================="
echo "  Graphiti MCP Server 启动"
echo "=========================================="

cd "$MCP_DIR"

echo "📦 启动服务..."
docker compose --env-file .env -f "$COMPOSE_FILE" up -d

echo ""
echo "⏳ 等待服务启动..."
sleep 5

echo ""
echo "📊 检查容器状态..."
podman ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(graphiti|neo4j)" || true

echo ""
echo "🔍 健康检查..."
for i in {1..12}; do
    if curl -s http://localhost:8000/health | grep -q "healthy"; then
        echo "✅ MCP Server 启动成功!"
        echo ""
        echo "=========================================="
        echo "  服务访问信息"
        echo "=========================================="
        echo "  MCP 端点:      http://localhost:8000/mcp"
        echo "  健康检查:      http://localhost:8000/health"
        echo "  Neo4j Browser: http://localhost:7474"
        echo "=========================================="
        exit 0
    fi
    echo "   等待中... ($i/12)"
    sleep 5
done

echo "❌ 启动超时，请检查日志:"
echo "   podman logs docker-graphiti-mcp-1"
exit 1
