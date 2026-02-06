#!/bin/bash
# Graphiti MCP Server 状态检查脚本
# 用法: ./mcp-status.sh

echo "=========================================="
echo "  Graphiti MCP Server 状态"
echo "=========================================="

echo ""
echo "📊 容器状态:"
echo "-------------------------------------------"
podman ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(NAMES|graphiti|neo4j)" || echo "  未找到相关容器"

echo ""
echo "🔍 健康检查:"
echo "-------------------------------------------"
HEALTH=$(curl -s http://localhost:8000/health 2>/dev/null)
if [[ -n "$HEALTH" ]]; then
    echo "  MCP Server: $HEALTH"
else
    echo "  MCP Server: ❌ 无法连接"
fi

echo ""
echo "🗄️  Neo4j 状态:"
echo "-------------------------------------------"
if curl -s http://localhost:7474 >/dev/null 2>&1; then
    echo "  Neo4j Browser: ✅ 可访问 (http://localhost:7474)"
else
    echo "  Neo4j Browser: ❌ 无法连接"
fi

echo ""
echo "📝 最近日志 (最后 10 行):"
echo "-------------------------------------------"
podman logs --tail 10 docker-graphiti-mcp-1 2>/dev/null | grep -E "(INFO|ERROR|WARNING)" || echo "  无日志或容器未运行"

echo ""
echo "=========================================="
