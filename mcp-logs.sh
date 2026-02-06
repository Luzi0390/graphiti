#!/bin/bash
# Graphiti MCP Server 日志查看脚本
# 用法: ./mcp-logs.sh [--follow] [--lines N]

# 默认参数
FOLLOW=""
LINES="100"

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--follow)
            FOLLOW="-f"
            shift
            ;;
        -n|--lines)
            LINES="$2"
            shift 2
            ;;
        *)
            echo "用法: $0 [--follow] [--lines N]"
            echo "  -f, --follow    实时跟踪日志"
            echo "  -n, --lines N   显示最后 N 行 (默认 100)"
            exit 1
            ;;
    esac
done

echo "=========================================="
echo "  Graphiti MCP Server 日志"
echo "=========================================="

if [[ -n "$FOLLOW" ]]; then
    echo "📜 实时跟踪日志 (Ctrl+C 退出)..."
    echo ""
    podman logs $FOLLOW docker-graphiti-mcp-1
else
    echo "📜 显示最后 $LINES 行日志..."
    echo ""
    podman logs --tail "$LINES" docker-graphiti-mcp-1
fi
