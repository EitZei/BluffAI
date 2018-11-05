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

local function printPropability(propability)
  print(propability.amount .. " of " .. propability.value .. " -> conscious: " .. propability.conscious .. " blind: " .. propability.blind)
end

local function printPropabilities (propabilities)
  for k, v in pairs(propabilities) do
    io.write(k .. ": " .. v .. " ")
  end
  io.write("\n")
end

local function ncr (n, k)
  res = 1;

  if k > (n - k) then
    k = n - k
  end

  for i = 0,(k-1) do
    res = res * (n - i)
    res = res / (i + 1)
  end

  return res;
end

local function binomialPropb (n, k, p)
  return ncr(n, k) * p^k * (1 - p)^(n-k)
end

local function dicesOfValue (value, dices)
  count = 0
  for k, v in pairs(dices) do
    if v == value or v == global.star then
      count = count + 1
    end
  end

  return count
end

local function getPropability (promise, totalDiceCount, ownDices)
  unknownDiceCount = totalDiceCount - #ownDices

  if promise.value == global.star then
    valuePropability = 1 / 6
  else
    valuePropability = 2 / 6
  end

  -- First the blind case...
  n = totalDiceCount
  k = promise.amount

  blind = 0
  for i = k, totalDiceCount do
    blind = blind + binomialPropb(n, i, valuePropability)
  end

  -- ... then the conscious case
  ownDiceOfValueCount = dicesOfValue(promise.value, ownDices)

  if unknownDiceCount + ownDiceOfValueCount < promise.amount then
    -- Even if all the unknown were of given value there wouldn't be requested amount
    conscious = 0
  elseif ownDiceOfValueCount >= promise.amount then
    -- Own dices by themselves cover the case
    conscious = 1
  else
    n = unknownDiceCount
    k = math.max(0, promise.amount - ownDiceOfValueCount)

    conscious = 0
    for i = k, totalDiceCount do
      conscious = conscious + binomialPropb(n, i, valuePropability)
    end
  end

  return {
    value = promise.value,
    amount = promise.amount,
    index = promise.index,
    blind = blind,
    conscious = conscious
  }
end

local function countPropabilities (game)
  ownDices = game.playerDices[game.playerInTurn]
  totalDiceCount = utils.totalNumberOfDices(game)

  if game.promise ~= nil then
    promisePropability = getPropability(game.promise, totalDiceCount, ownDices)
  end

  availableStates = utils.getAvailableStates(game)

  -- Computationally stupid we know the
  statePropabilities = {}
  for k, v in pairs(availableStates) do
    table.insert(statePropabilities, getPropability(v, totalDiceCount, ownDices))
  end

  return promisePropability, statePropabilities
end

local function toPromise (propability)
  return {
    amount = propability.amount,
    value = propability.value,
    index = propability.index
  }
end

local function addRandomness(value, level)
  return value + (math.random() * level - (level / 2))
end

local function play (game)
  promisePropability, statePropabilities = countPropabilities(game)

  --[[
  print("\nPlayer " .. game.playerInTurn .. " sees propabilities")
  if game.promise ~= nil then
    print("For current promise:")
    printPropability(promisePropability)
  end
  print("For available states:")
  for k, v in pairs(statePropabilities) do
    printPropability(v)
  end
  ]]--

  pSuspicious = addRandomness(0.3, 0.1)
  pThreshold = addRandomness(0.7, 0.1)

  chooseDiffest = 0.2
  chooseStillProbable = 0.2
  chooseBest = 0.5
  chooseNext = 0.1

  -- If we know the propability is less than threshold and our info is better for calling ...
  if game.promise ~= nil and promisePropability.conscious < pSuspicious and (promisePropability.conscious < promisePropability.blind) then
    return nil
  end

  -- ... and the rest is mystery. Either promise the next, most probable
  -- or the one with most information supremacy.
  next = nil
  best = { conscious = 0, blind = 0 }
  diffest = { conscious = 0, blind = 0 }
  stillProbable = { conscious = 0, blind = 0 }
  for k, v in pairs(statePropabilities) do
    if (next == nil) then
      next = v
    end

    if v.conscious > pThreshold then
      stillProbable = v
    end

    if v.conscious > best.conscious then
      best = v
    end

    if (v.conscious - v.blind) > (diffest.conscious - diffest.blind) then
      diffest = v
    end
  end

  r = math.random()

  if (game.promise == nil or r < chooseStillProbable) and stillProbable.conscious ~= 0 then
    return toPromise(stillProbable)
  elseif r < (chooseDiffest + chooseStillProbable) and diffest.conscious ~= 0 then
    return toPromise(diffest)
  elseif r < (chooseBest + chooseDiffest + chooseStillProbable) and best.conscious ~= 0 then
    return toPromise(best)
  else
    return toPromise(next)
  end
end

return {
  play = play
}