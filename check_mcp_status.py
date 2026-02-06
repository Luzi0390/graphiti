
import asyncio
from mcp.client.streamable_http import streamablehttp_client
from mcp.client.session import ClientSession

async def check_status():
    base_url = "http://127.0.0.1:8000/mcp/"
    try:
        async with streamablehttp_client(base_url) as streams:
            read_stream, write_stream = streams[:2]
            async with ClientSession(read_stream, write_stream) as session:
                await session.initialize()
                result = await session.call_tool("get_status", {})
                print(f"Status: {result.content[0].text}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    asyncio.run(check_status())
