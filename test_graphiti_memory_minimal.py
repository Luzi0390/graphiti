
import asyncio
import json
import time
from mcp.client.streamable_http import streamablehttp_client
from mcp.client.session import ClientSession

async def test_memory():
    base_url = "http://127.0.0.1:8000/mcp/"
    print(f"Connecting to {base_url}...")
    
    try:
        async with streamablehttp_client(base_url) as streams:
            read_stream, write_stream = streams[:2]
            async with ClientSession(read_stream, write_stream) as session:
                print("Initializing session...")
                await session.initialize()
                print("Session initialized.")
                
                test_group = f"test_group_{int(time.time())}"
                test_content = "The secret code for the vault is 12345. This was recorded on Feb 6, 2026."
                
                print("Clearing graph...")
                await session.call_tool("clear_graph", {})
                
                print(f"Adding memory to group {test_group}...")
                result = await session.call_tool(
                    "add_memory",
                    {
                        "name": "Secret Vault Code",
                        "episode_body": test_content,
                        "group_id": test_group
                    }
                )
                print(f"Add memory result: {result}")
                
                print("Waiting for processing (60s)...")
                await asyncio.sleep(60)
                
                print(f"Retrieving episodes for group {test_group}...")
                result = await session.call_tool(
                    "get_episodes",
                    {
                        "group_ids": [test_group]
                    }
                )
                print(f"Get episodes result: {result.content[0].text if result.content else 'No content'}")
                
                print(f"Searching for nodes related to 'vault code' in group {test_group}...")
                result = await session.call_tool(
                    "search_nodes",
                    {
                        "query": "vault code",
                        "group_ids": [test_group]
                    }
                )
                print(f"Search nodes result: {result.content[0].text if result.content else 'No content'}")

    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    asyncio.run(test_memory())
