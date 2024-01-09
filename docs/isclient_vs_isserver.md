# Global Functions isClient and isServer

`isClient()` and `isServer()` are global LUA functions available in Project Zomboid
to make handling different environments easier.

Originally from Tyrir in Discord:

| Environment                   | isClient() | isServer() |
|-------------------------------|------------|------------|
| Singleplayer                  | false      | false      |
| Multiplayer Client            | true       | false      |
| Co-op Host (client process)   | true       | false      |
| Co-op Host (server process)   | false      | true       |
| Dedicated Server              | false      | true       |

These functions are required because the `client`, `shared` `server` directories may not behave as you may expect.

Single player and client multiplayer loads `shared`, THEN `client`, THEN `server`.
All 3 directory contents are loaded by the client.

For servers, just `shared` and then `server` are loaded, (`client` is omitted here).

Examples:

```lua
-- Run some operation ONLY on the server (does not run in single player)
if isServer() then
    -- do something
end

-- Run some operation either on the server OR in single player
if not isClient() then
    -- do something
end

-- Run some operation either on the client in MP OR in single player
if not isServer() then
    -- do something
end
```
