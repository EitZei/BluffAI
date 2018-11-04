# BluffAI

Enjoy the great dice game Bluff with quite stupid bots.

## Dependencies
- Lua 5.3 (or Docker)

## Run
`lua game.lua``

### Docker
`docker build -t bluff-ai .`
`docker run bluff-ai`

## Contributing

If you would like to implement new strategy see the `lib/strategies/idiot.lua` for reference. Then implement new strategy and register it ad `lib/strategies.lua` to get it running.