global = require "lib/global"
utils = require "lib/utils"

local function getValidPromise (amount, value, game)
  availableStates = utils.getAvailableStates(game)

  for k, v in pairs(availableStates) do
    if v.amount == amount and v.value == value then
      return v
    end
  end

  return nil
end

local function printNextStates (game)
  availableStates = utils.getAvailableStates(game)

  amount = 0

  io.write("Next states: ")
  for k, v in pairs(availableStates) do
    if v.amount ~= amount then
      amount = v.amount

      value = ""
      if v.value == global.star then value = global.star end

      io.write(amount .. value .. " ")
    end
  end
  print()
end

local function play (game)
  print()
  print("Your turn player" .. game.playerInTurn .. "!")
  printNextStates(game)
  print()

  nextPromise = nil

  while nextPromise == nil do
    amount = -1
    while amount < 0 do
      io.write("How many dices (0 = call)? ")
      amount = io.read("*number")
      io.read()
    end
    print()

    -- Call
    if (amount == 0) then return nil end

    value = 0
    while value < 1 or value > 6 do
      io.write("Which value (6 = star)? ")
      value = io.read("*number")
      io.read()
    end
    print()

    if (value == 6) then value = global.star end

    nextPromise = getValidPromise(amount, value, game)

    if (nextPromise == nil) then
      print(amount .. " of " .. value .. " is not valid promise!")
    end
  end

  return nextPromise
end

return {
  play = play
}
