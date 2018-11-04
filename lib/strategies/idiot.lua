global = require "lib/global"
utils = require "lib/utils"

local function countDistribution (ownDices, totalDiceCount)
  unknownDiceCount = totalDiceCount - #ownDices

  distribution = {}
  for k, v in pairs(global.diceValues) do
    ownCount = 0
    for ok, ov in pairs(ownDices) do
      if ov == v or ov == global.star then
        ownCount = ownCount + 1
      end
    end

    if v == global.star then
      expectedUnknown = unknownDiceCount / #global.diceValues
    else
      expectedUnknown = 2 * (unknownDiceCount / #global.diceValues)
    end

    distribution[v] = expectedUnknown + ownCount
  end

  return distribution
end

local function printPropabilities (propabilities)
  for k, v in pairs(propabilities) do
    io.write(k .. ": " .. v .. " ")
  end
  io.write("\n")
end

local function play (game)
  totalDiceCount = utils.totalNumberOfDices(game)
  playerPropabilities = countDistribution(game.playerDices[game.playerInTurn], totalDiceCount)
  --print("\nPlayer " .. game.playerInTurn .. " sees propabilities")
  --printPropabilities(playerPropabilities)

  availableStates = utils.getAvailableStates(game)

  largest = nil
  for k, v in pairs(availableStates) do
    if playerPropabilities[v.value] > v.amount then
      largest = v
    end
  end

  -- Go for the largest that you can estimate. If that is not available
  -- take 50/50 on minimal raise or call.
  if largest ~= nil then
    print("Player " .. game.playerInTurn .. " promises " .. largest.amount .. " of " .. largest.value)
    return largest
  elseif math.random() > 0.5 then
    print("Player " .. game.playerInTurn .. " promises " .. availableStates[1].amount .. " of " .. availableStates[1].value)
    return availableStates[1]
  else
    print("Player " .. game.playerInTurn .. " calls")
    return nil
  end
end

return {
  play = play
}