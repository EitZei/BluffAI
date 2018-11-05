global = require "lib/global"
utils = require "lib/utils"
strategies = require "lib/strategies"

math.randomseed(os.time())

local function printGameState (game, showAllAnyways)
  io.write("\n")
  for playerNo, playerDice in pairs(game.playerDices) do
    io.write("Player " .. playerNo .. ": ")
    if showAllAnyways or playParams.humanPlayer == nil or playParams.humanPlayer == playerNo then
      for i, dice in pairs(playerDice) do io.write(dice .. " ") end
    else
      io.write(game.playerDiceCounts[playerNo] .. " dices")
    end
    io.write("\n")
  end
  io.write("\n")
end

local function initPlayerStrategies(playParams)
  strategyNames = {}

  for k,v in pairs(strategies.aiStrategies) do
    table.insert(strategyNames, k)
  end

  playerStrategies = {}

  for i=1, playParams.numberOfPlayers do
    if playParams.humanPlayer ~= nil and i == playParams.humanPlayer then
      strategyName = "human"
      strategy = strategies.humanStrategy
    else
      strategyName = strategyNames[math.random(1, #strategyNames)]
      strategy = strategies.aiStrategies[strategyName]
    end

    playerStrategies[i] = strategy
    --print("Player " .. i .. " will play with strategy \"" .. strategyName .. "\"")
  end

  return playerStrategies
end

local function initPlayerDiceCounts (playParams)
  playerDiceCounts = {}

  for i=1, playParams.numberOfPlayers do
    playerDiceCounts[i] = playParams.numberOfDices
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

local function play (playParams)
  game = {
    board = board,
    previousPlayerInTurn = nil,
    playerInTurn = 1,
    playerDiceCounts = initPlayerDiceCounts(playParams),
    promise = nil,
    playerDices = nil,
    playerStrategies = initPlayerStrategies(playParams)
  }

  print("##### Game starts #####")
  while utils.moreThanOneHasDice(game) do
    if game.promise == nil then
      if playParams.humanPlayer ~= nil then
        print()
        print("Press return to continue.")
        io.read()
        utils.clearScreen()
      end

      game.playerDices = utils.rollDices(game)
      print("\n## New round (" .. utils.totalNumberOfDices(game) .. ") ##")
      printGameState(game, false)
    end

    -- Execute player strategy
    nextPromise = playAsPlayer(game)

    -- Call or raise?
    if nextPromise == nil then
      print("Player " .. game.playerInTurn .. " calls")

      if playParams.humanPlayer ~= nil then
        printGameState(game, true)
      end

      -- Count dices..
      actualDices = utils.countDicesOfPromisedValue(game)

      print("Promise was " .. game.promise.amount .. " of " .. game.promise.value .. " and there was " .. actualDices)

      if actualDices == game.promise.amount then
        -- Everyone except previous player loses one
        print("Communist attack! Everyone else than the one who promised loses one dice")
        for k, v in pairs(game.playerDiceCounts) do
          -- Note that communist cannot take the last dice
          if (k ~= game.previousPlayerInTurn) and (k == game.playerInTurn or game.playerDiceCounts[k] > 1) then
            game.playerDiceCounts[k] = game.playerDiceCounts[k] - 1
          end
        end

        game.playerInTurn = game.previousPlayerInTurn
      elseif actualDices > game.promise.amount then
        -- The player who called loses the difference
        diff = math.min(game.playerDiceCounts[game.playerInTurn], actualDices - game.promise.amount)
        print("Bad call. Player " .. game.playerInTurn .. " loses " .. diff .. " dices")
        game.playerDiceCounts[game.playerInTurn] = game.playerDiceCounts[game.playerInTurn] - diff

        if game.playerDiceCounts[game.playerInTurn] == 0 then
          print("Player " .. game.playerInTurn .. " is out of game!")
        end

        game.playerInTurn = game.previousPlayerInTurn
      else
        -- Previous player loses the difference
        diff = math.min(game.playerDiceCounts[game.previousPlayerInTurn], game.promise.amount - actualDices)
        print("Bad promise. Player " .. game.previousPlayerInTurn .. " loses " .. diff .. " dices")
        game.playerDiceCounts[game.previousPlayerInTurn] = game.playerDiceCounts[game.previousPlayerInTurn] - diff

        if game.playerDiceCounts[game.previousPlayerInTurn] == 0 then
          print("Player " .. game.previousPlayerInTurn .. " is out of game!")
        end

        game.playerInTurn = game.playerInTurn
      end

      game.promise = nil
      game.previousPlayerInTurn = nil
    else
      print("Player " .. game.playerInTurn .. " promises " .. nextPromise.amount .. " of " .. nextPromise.value)
      game.promise = nextPromise
      game.previousPlayerInTurn = game.playerInTurn

      repeat
        -- Merry go around
        if game.playerInTurn == playParams.numberOfPlayers then
          game.playerInTurn = 1
        else
          game.playerInTurn = game.playerInTurn + 1
        end
      until(utils.currentPlayerHasDices(game))
    end
  end

  print("\n##### Player " .. game.playerInTurn .. " won! #####")
end

return {
  play = play
}