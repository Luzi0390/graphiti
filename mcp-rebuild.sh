#!/bin/bash
# Graphiti MCP Server 重新构建脚本
# 用法: ./mcp-rebuild.sh [--no-cache]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MCP_DIR="$SCRIPT_DIR/mcp_server"
COMPOSE_FILE="docker/docker-compose-gemini-neo4j.yml"

# 设置临时目录，如果 /data/tmp 存在则优先使用，解决 /var 空间不足的问题
if [ -d "/data/tmp" ]; then
    export TMPDIR="/data/tmp"
    export BUILDAH_TMPDIR="/data/tmp"
    export PODMAN_TMPDIR="/data/tmp"
    # Podman-compose 也会参考这些变量
    export DOCKER_TMPDIR="/data/tmp"
    echo "📂 使用临时目录: $TMPDIR (解决 /var 空间不足问题)"
    
    # 确保目录存在并可写
    mkdir -p /data/tmp
fi

# 解析参数
NO_CACHE=""
if [[ "$1" == "--no-cache" ]]; then
    NO_CACHE="--no-cache"
    echo "🔄 使用 --no-cache 模式"
fi

echo "=========================================="
echo "  Graphiti MCP Server 重新构建"
echo "=========================================="

cd "$MCP_DIR"

echo "🛑 停止旧服务..."
docker compose --env-file .env -f "$COMPOSE_FILE" down 2>/dev/null || true

echo "🧹 清理未使用的构建缓存..."
podman system prune -f || true

echo ""
echo "🔨 构建镜像 (这可能需要几分钟)..."
# 再次确保环境变量在执行 build 命令时生效
TMPDIR="/data/tmp" BUILDAH_TMPDIR="/data/tmp" PODMAN_TMPDIR="/data/tmp" \
docker compose --env-file .env -f "$COMPOSE_FILE" build $NO_CACHE graphiti-mcp

echo ""
echo "📦 启动新服务..."
docker compose --env-file .env -f "$COMPOSE_FILE" up -d

echo ""
echo "⏳ 等待服务启动..."
sleep 10

echo ""
echo "📊 检查容器状态..."
podman ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(graphiti|neo4j)" || true

echo ""
echo "🔍 健康检查..."
for i in {1..12}; do
    if curl -s http://localhost:8000/health | grep -q "healthy"; then
        echo "✅ 重建并启动成功!"
        exit 0
    fi
    echo "   等待中... ($i/12)"
    sleep 5
done

echo "❌ 启动超时，请检查日志:"
echo "   podman logs docker-graphiti-mcp-1"
exit 1
