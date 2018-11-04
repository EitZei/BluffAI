global = require "lib/global"
utils = require "lib/utils"
strategies = require "lib/strategies"

numberOfPlayers = 6
numberOfDices = 5

math.randomseed(os.time())

local function printGameState (game)
  io.write("\n")
  for playerNo, playerDice in pairs(game.playerDices) do
    io.write("Player " .. playerNo .. ": ")
    for i, dice in pairs(playerDice) do io.write(dice .. " ") end
    io.write("\n")
  end
  io.write("\n")
end

local function initPlayerStrategies(numberOfPlayers)
  strategyNames = {}

  for k,v in pairs(strategies) do
    table.insert(strategyNames, k)
  end

  playerStrategies = {}

  for i=1,numberOfPlayers do
    strategyName = strategyNames[math.random(1, #strategyNames)]
    strategy = strategies[strategyName]
    playerStrategies[i] = strategy
    print("Player " .. i .. " will play with strategy \"" .. strategyName .. "\"")
  end

  return playerStrategies
end

local function initPlayerDiceCounts (numberOfPlayers)
  playerDiceCounts = {}

  for i=1,numberOfPlayers do
    playerDiceCounts[i] = numberOfDices
  end

  return playerDiceCounts
end

local function playAsPlayer (game)
  -- Create copy of a game but without the hands of other players

  forPlayer = {
    board = game.board,
    playerInTurn = game.playerInTurn,
    playerDiceCounts = game.playerDiceCounts,
    promise = game.promise,
    playerDices = {}
  }

  forPlayer.playerDices[game.playerInTurn] = game.playerDices[game.playerInTurn]

  return game.playerStrategies[game.playerInTurn](forPlayer)
end

game = {
  board = board,
  previousPlayerInTurn = nil,
  playerInTurn = 1,
  playerDiceCounts = initPlayerDiceCounts(numberOfPlayers),
  promise = nil,
  playerDices = nil,
  playerStrategies = initPlayerStrategies(numberOfPlayers)
}

print("\n##### Game starts #####")
while utils.moreThanOneHasDice(game) do
  if game.promise == nil then
    game.playerDices = utils.rollDices(game)
    print("\n## New round ##")
    printGameState(game)
  end

  -- Execute player strategy
  nextPromise = playAsPlayer(game)

  -- Call or raise?
  if nextPromise == nil then
    -- Count dices..
    actualDices = utils.countDicesOfPromisedValue(game)

    print("Promise was " .. game.promise.amount .. " of " .. game.promise.value .. " and there was " .. actualDices)

    if actualDices == game.promise.amount then
      -- Everyone except previous player loses one
      print("Communist attack! Everyone else than the one who promised loses one dice")
      for k, v in pairs(game.playerDiceCounts) do
        -- Note that communist cannot take the last dice
        if (k ~= game.previousPlayerInTurn) and game.playerDiceCounts[k] > 1 then
          game.playerDiceCounts[k] = game.playerDiceCounts[k] - 1
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
    until(utils.currentPlayerHasDices(game))
  end

  -- io.read()
end

print("\n##### Player " .. game.playerInTurn .. " won! #####")