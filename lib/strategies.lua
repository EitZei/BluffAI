local aiStrategies = {}
aiStrategies["idiot"] = (require "lib/strategies/idiot").play
aiStrategies["nerdy"] = (require "lib/strategies/nerdy").play

local humanStrategy = (require "lib/strategies/human").play

return {
  aiStrategies = aiStrategies,
  humanStrategy = humanStrategy
}