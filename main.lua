math.randomseed(os.time())

game = require "lib/game"

print("If you just want watch as bots play run with flag 'only-bots'")

onlyBots = false

playParams = {
  numberOfPlayers = 6,
  numberOfDices = 5,
  gameStyle = nil,
  thePlayers = nil
}

for k, v in pairs(arg) do
  if v == "only-bots" then onlyBots = true end
end

if onlyBots then
  playParams.gameStyle = global.gameStyle.onlyBots;
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
  playParams.gameStyle = global.gameStyle.botVsHumans;

  io.write("How many players: ")
  playParams.numberOfPlayers = io.read("*number")
  io.read()

  io.write("How many dices per player: ")
  playParams.numberOfDices = io.read("*number")
  io.read()

  while
    playParams.thePlayer == nil or
    playParams.thePlayer < 1 or
    playParams.thePlayer > playParams.numberOfPlayers do

    io.write("Whats your position (1.." .. playParams.numberOfPlayers .. "): ")
    playParams.thePlayer = io.read("*number")
    io.read()
  end
  print()
elseif selection == 1 then
  playParams.gameStyle = global.gameStyle.humanVsBots;

  playParams.thePlayer = math.random(1, playParams.numberOfPlayers)
  print("You will be player " .. playParams.thePlayer .. ".")
  print()
end

game.play(playParams)
