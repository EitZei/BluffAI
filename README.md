# BluffAI

Enjoy the great dice game Bluff with quite stupid bots.

You can either play by yourself or watch the bots play.

## Dependencies
- Lua 5.3 (or Docker)

## Run

`lua main.lua` or to just watch the bots play `lua main.lua only-bots`

### Docker

`docker build -t bluff-ai .`

`docker run -it bluff-ai`

## Contributing

If you would like to implement new strategy see the `lib/strategies/idiot.lua` for reference. Then implement new strategy and register it ad `lib/strategies.lua` to get it running.