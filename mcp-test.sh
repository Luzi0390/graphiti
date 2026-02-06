#!/bin/bash
# Graphiti MCP Server 测试脚本
# 用法: ./mcp-test.sh

echo "=========================================="
echo "  Graphiti MCP Server 测试"
echo "=========================================="

# 测试 1: 健康检查
echo ""
echo "[1/3] 健康检查..."
HEALTH=$(curl -s http://localhost:8000/health)
if echo "$HEALTH" | grep -q "healthy"; then
    echo "  ✅ 通过: $HEALTH"
else
    echo "  ❌ 失败: 服务未响应"
    exit 1
fi

# 测试 2: MCP 初始化
echo ""
echo "[2/3] MCP 协议初始化..."
INIT_RESPONSE=$(curl -s -X POST http://localhost:8000/mcp \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "initialize",
    "params": {
      "protocolVersion": "2024-11-05",
      "capabilities": {},
      "clientInfo": {"name": "test-client", "version": "1.0.0"}
    }
  }')

if echo "$INIT_RESPONSE" | grep -q "Graphiti Agent Memory"; then
    echo "  ✅ 通过: MCP 协议正常"
else
    echo "  ⚠️  警告: MCP 响应异常"
    echo "  响应: ${INIT_RESPONSE:0:200}..."
fi

# 测试 3: Neo4j 连接
echo ""
echo "[3/3] Neo4j 数据库..."
if curl -s http://localhost:7474 >/dev/null 2>&1; then
    echo "  ✅ 通过: Neo4j 可访问"
else
    echo "  ❌ 失败: Neo4j 无法连接"
fi

echo ""
echo "=========================================="
echo "  测试完成"
echo "=========================================="
echo ""
echo "服务访问地址:"
echo "  MCP 端点:      http://localhost:8000/mcp"
echo "  健康检查:      http://localhost:8000/health"
echo "  Neo4j Browser: http://localhost:7474"
echo "  Neo4j 用户名:  neo4j"
echo "  Neo4j 密码:    graphiti_secure_2024"
echo "=========================================="
