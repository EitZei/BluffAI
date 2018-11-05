local strategies = {}
strategies["idiot"] = (require "lib/strategies/idiot").play
strategies["nerdy"] = (require "lib/strategies/nerdy").play

return strategies