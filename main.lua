math.randomseed(os.time())

star = "★"
diceValues = { 1, 2, 3, 4, 5, star }

function addAllDices (amount, board)
  for k, v in pairs(diceValues) do
    if (v ~= star) then
      state = { amount = amount, value = v, index = #board + 1 }
      table.insert(board, state)
    end
  end
end

function createBoard ()
  board = {}

  addAllDices(1, board)

  normalCount = 2
  starCount = 1

  for i = 1,10 do
    table.insert(board, { amount = starCount, value = star, index = #board + 1 })
    starCount = starCount + 1

    addAllDices(normalCount, board)
    normalCount = normalCount + 1

    addAllDices(normalCount, board)
    normalCount = normalCount + 1
  end

  return board;
end

board = createBoard()

function rollDices (playerDiceCounts)
  playerDices = {}

  for i=1, #playerDiceCounts do
    playerDices[i] = {}
    for j=1, playerDiceCounts[i] do
      playerDices[i][j] = diceValues[math.random(1, #diceValues)]
    end
  end

  return playerDices
end

function printGameState (game)
  io.write("\n")
  for playerNo, playerDice in pairs(game.playerDices) do
    io.write("Player " .. playerNo .. ": ")
    for i, dice in pairs(playerDice) do io.write(dice .. " ") end
    io.write("\n")
  end
  io.write("\n")
end

function countDistribution (ownDices, totalDiceCount)
  unknownDiceCount = totalDiceCount - #ownDices

  distribution = {}
  for k, v in pairs(diceValues) do
    ownCount = 0
    for ok, ov in pairs(ownDices) do
      if ov == v or ov == star then
        ownCount = ownCount + 1
      end
    end

    if v == star then
      expectedUnknown = unknownDiceCount / #diceValues
    else
      expectedUnknown = 2 * (unknownDiceCount / #diceValues)
    end

    distribution[v] = expectedUnknown + ownCount
  end

  return distribution
end

function moreThanOneHasDice (game)
  hasDicesCount = 0

  for k, v in pairs(game.playerDiceCounts) do
    if v > 0 then hasDicesCount = hasDicesCount + 1 end

    if hasDicesCount > 1 then return true end
  end

  return false
end

function totalNumberOfDices (game)
  diceCount = 0

  for k, v in pairs(game.playerDices) do
    diceCount = diceCount + #v
  end

  return diceCount
end

function printPropabilities (propabilities)
  for k, v in pairs(propabilities) do
    io.write(k .. ": " .. v .. " ")
  end
  io.write("\n")
end

function getAvailableStates (game)
  if game.promise == nil then
    return game.board
  else
    return { table.unpack(game.board, game.promise.index + 1) }
  end
end

function countDicesOfPromisedValue(game)
  value = game.promise.value

  count = 0

  for k1, player in pairs(game.playerDices) do
    for k2, dice in pairs(player) do
      if dice == value or dice == star then
        count = count + 1
      end
    end
  end

  return count
end

function currentPlayerHasDices(game)
  return game.playerDiceCounts[game.playerInTurn] > 0
end


function idiotStrategy (game)
  totalDiceCount = totalNumberOfDices(game)
  playerPropabilities = countDistribution(game.playerDices[game.playerInTurn], totalDiceCount)
  --print("\nPlayer " .. game.playerInTurn .. " sees propabilities")
  --printPropabilities(playerPropabilities)

  availableStates = getAvailableStates(game)

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

strategies = {}
strategies["idiot"] = idiotStrategy

function playAsPlayer (game)
  return strategies.idiot(game)
end

numberOfPlayers = 6
numberOfDices = 5

playerDiceCounts = {}

for i=1,numberOfPlayers do
  playerDiceCounts[i] = numberOfDices
end

game = {
  board = board,
  previousPlayerInTurn = nil,
  playerInTurn = 1,
  playerDiceCounts = playerDiceCounts,
  promise = nil,
  playerDices = nil
}

print("##### Game starts #####")
while moreThanOneHasDice(game) do
  if game.promise == nil then
    game.playerDices = rollDices(playerDiceCounts)
    print("\n## New round ##")
    printGameState(game)
  end

  nextPromise = playAsPlayer(game)

  -- Call or raise?
  if nextPromise == nil then
    -- Count dices..
    actualDices = countDicesOfPromisedValue(game)

    print("Promise was " .. game.promise.amount .. " of " .. game.promise.value .. " and there was " .. actualDices)

    if actualDices == game.promise.amount then
      -- Everyone except previous player loses one
      print("Communist attack! Everyone else than the one who promised loses one dice")
      for k, v in pairs(game.playerDiceCounts) do
        if (k ~= game.previousPlayerInTurn) then
          -- Note that communist cannot take the last dice
          game.playerDiceCounts[k] = math.max(1, game.playerDiceCounts[k] - 1)
        end
      end

      game.playerInTurn = game.previousPlayerInTurn
    elseif actualDices > game.promise.amount then
      -- The player who called loses the difference
      diff = actualDices - game.promise.amount
      print("Bad call. Player " .. game.playerInTurn .. " loses " .. diff .. " dices")
      game.playerDiceCounts[game.playerInTurn] = math.max(0, game.playerDiceCounts[game.playerInTurn] - diff)

      game.playerInTurn = game.previousPlayerInTurn
    else
      -- Previous player loses the difference
      diff =  game.promise.amount - actualDices
      print("Bad promise. Player " .. game.previousPlayerInTurn .. " loses " .. diff .. " dices")
      game.playerDiceCounts[game.previousPlayerInTurn] = math.max(0, game.playerDiceCounts[game.previousPlayerInTurn] - diff)

      game.playerInTurn = game.playerInTurn
    end

    game.promise = nil
    game.previousPlayerInTurn = nil
  else
    game.promise = nextPromise
    game.previousPlayerInTurn = game.playerInTurn
    repeat
      -- Merry go around
      if game.playerInTurn == numberOfPlayers then
        game.playerInTurn = 1
      else
        game.playerInTurn = game.playerInTurn + 1
      end
    until(currentPlayerHasDices(game))
  end

  -- io.read()
end

print("\n##### Player " .. game.playerInTurn .. " won! #####")