local function totalNumberOfDices (game)
  diceCount = 0

  for k, v in pairs(game.playerDices) do
    diceCount = diceCount + #v
  end

  return diceCount
end

local function getAvailableStates (game)
  if game.promise == nil then
    return game.board
  else
    return { table.unpack(game.board, game.promise.index + 1) }
  end
end

local function rollDices (playerDiceCounts)
  playerDices = {}

  for i=1, #playerDiceCounts do
    playerDices[i] = {}
    for j=1, playerDiceCounts[i] do
      playerDices[i][j] = global.diceValues[math.random(1, #global.diceValues)]
    end
  end

  return playerDices
end

local function moreThanOneHasDice (game)
  hasDicesCount = 0

  for k, v in pairs(game.playerDiceCounts) do
    if v > 0 then hasDicesCount = hasDicesCount + 1 end

    if hasDicesCount > 1 then return true end
  end

  return false
end

local function countDicesOfPromisedValue(game)
  value = game.promise.value

  count = 0

  for k1, player in pairs(game.playerDices) do
    for k2, dice in pairs(player) do
      if dice == value or dice == global.star then
        count = count + 1
      end
    end
  end

  return count
end

local function currentPlayerHasDices(game)
  return game.playerDiceCounts[game.playerInTurn] > 0
end

return {
  totalNumberOfDices = totalNumberOfDices,
  getAvailableStates = getAvailableStates,
  rollDices = rollDices,
  moreThanOneHasDice = moreThanOneHasDice,
  countDicesOfPromisedValue = countDicesOfPromisedValue,
  currentPlayerHasDices = currentPlayerHasDices,
}