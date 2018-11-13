local function totalNumberOfDices (game)
  diceCount = 0

  for k, v in pairs(game.playerDiceCounts) do
    diceCount = diceCount + v
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

local function rollDices (game)
  playerDices = {}

  for i=1, #game.playerDiceCounts do
    playerDices[i] = {}
    for j=1, playerDiceCounts[i] do
      if game.gameStyle == global.gameStyle.botVsHumans and game.thePlayer == i then
        dice = nil

        while dice == nil or dice < 1 or dice > 6 do
          io.write("Dice value (6 = star): ")
          dice = io.read("*number")
          io.read()
        end

        if dice == 6 then dice = global.star end
        playerDices[i][j] = dice
      else
        playerDices[i][j] = global.diceValues[math.random(1, #global.diceValues)]
      end
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

local function countDicesOfPromisedValue (game)
  value = game.promise.value

  if game.gameStyle == global.gameStyle.botVsHumans then
    io.write("How many dices of value " .. value .. " were there? ")
    count = io.read("*number")
    io.read()
  else
    count = 0

    for k1, player in pairs(game.playerDices) do
      for k2, dice in pairs(player) do
        if dice == value or dice == global.star then
          count = count + 1
        end
      end
    end
  end

  return count
end

local function currentPlayerHasDices (game)
  return game.playerDiceCounts[game.playerInTurn] > 0
end

local function clearScreen ()
  if not os.execute("clear") then
    os.execute("cls")
  elseif not os.execute("cls") then
    for i = 1,25 do
        print("\n\n")
    end
  end
end

return {
  totalNumberOfDices = totalNumberOfDices,
  getAvailableStates = getAvailableStates,
  rollDices = rollDices,
  moreThanOneHasDice = moreThanOneHasDice,
  countDicesOfPromisedValue = countDicesOfPromisedValue,
  currentPlayerHasDices = currentPlayerHasDices,
  clearScreen = clearScreen
}
