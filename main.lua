math.randomseed(os.time())

game = require "lib/game"

print("If you just want watch as bots play run with flag 'only-bots'")

onlyBots = false

playParams = {
  numberOfPlayers = 6,
  numberOfDices = 5,
  humanPlayer = nil
}

for k, v in pairs(arg) do
  if v == "only-bots" then onlyBots = true end
end

if onlyBots then
  game.play(playParams)
  return
end

selection = 0
while selection < 1 or selection > 2 do
  print()
  print("How would you like to play?")
  print("1) Me against bots")
  print("2) Me as a bot against humans")
  print()
  io.write("Mode: ")
  selection = io.read("*number")
  io.read()
end
print()

if selection == 2 then
  print("Not implemented. Sorry about that.")
elseif selection == 1 then
  playParams.humanPlayer = math.random(1, playParams.numberOfPlayers)
  print("You will be player " .. playParams.humanPlayer .. ".")
  print()

  game.play(playParams)
end