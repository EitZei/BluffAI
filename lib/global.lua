local star = "★"
local diceValues = { 1, 2, 3, 4, 5, star }

local gameStyle = {
  humanVsBots = 1,
  botVsHumans = 2,
  onlyBots = 3
}

local function addAllDices (amount, board)
  for k, v in pairs(diceValues) do
    if (v ~= star) then
      state = { amount = amount, value = v, index = #board + 1 }
      table.insert(board, state)
    end
  end
end

local function createBoard ()
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

return {
  star = star,
  diceValues = diceValues,
  board = createBoard(),
  gameStyle = gameStyle
}
