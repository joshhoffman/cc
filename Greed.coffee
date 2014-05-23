###
// This code runs once per frame. Build units and command peons!
// Destroy the human base within 180 seconds.
// Run over 4000 statements per call and chooseAction will run less often.
// Check out the green Guide button at the top for more info.
###

# TODO:
# Add conditions to strategies. Conditions onlyfire if they resolve to true
# Check the closest coint location for enemy peons. If one of my peons is closer
#  send him after that coin to block the enemy from picking it up

base = this

determineGoldCost = (units) ->
  totalCost = 0
  for e in units
    do(e) ->
      totalCost += base.buildables[e].goldCost
  return totalCost

removeFromArray = (obj, arr) ->
  count = 0
  this.arr = arr
  for item in arr
    do (item) ->
      if item.pos.x is obj.pos.x and item.pos.y is obj.pos.y
        this.arr.slice(count)
        count++
        return arr
  return arr

getUnitByType = (unitType, unitsToSearch) ->
  ret = []
  for entry in unitsToSearch
    do(entry) ->
      ret.push(entry) if entry.type is unitType
  return ret

isTargeted = (gatherers, item) ->
  for gatherer in gatherers
    do(gatherer) ->
      if gatherer.targetPos?
        if gatherer.targetPos.x is item.pos.x
          if gatherer.targetPos.y is item.pos.y
            #base.say 'true'
            return true
  return false

pruneItems = (myGatherers, enemyGatherers, itemsToSearch) ->
  ret = []
  for item in itemsToSearch
    do(item) ->
      if isTargeted(myGatherers, item) is false
        if isTargeted(enemyGatherers, item) is false
          ret.push item
  return ret

findClosestUnit = (targetUnit, unitsToSearch) ->
  min = 9001
  ret = null
  for entry in unitsToSearch
    do(entry) ->
      dist = this.targetUnit.distance entry
      if dist <= min
        min = dist
        ret = entry
  return entry

sign = (x) ->
  return (x > 0) - (x < 0)

findAndMoveToItem = (peon, itemsToSearch) ->
  item = peon.getNearest itemsToSearch
  if item
    base.command peon, 'move', item.pos
    return removeFromArray(item, itemsToSearch)
  return itemsToSearch

aboveOrBelow = (item) ->
  return sign((85-0)*(item.pos.y-0) - (75-0)*(item.pos.x-0))

if not @this.strategies
  @gatherer = 'peon'
  @healer = 'shaman'
  @tank = 'ogre'
  @trash = 'munchkin'
  @attack = 'fangrider'

  @enemyGatherer = 'peasant'
  @enemyTrash = 'soldier'

items = base.getItems()
peons = base.getByType @gatherer
enemyPeons = base.getByType @enemyGatherer
enemies = base.getEnemies()

numPeons = peons.length
numEnemyPeons = enemyPeons.length

###
var gatherer = 'peasant';
var healer = 'librarian';
var tank = 'knight';
var trash = 'soldier';
var attack = 'griffin-rider';

enemyGatherer = 'peon'
###



# Setup strategies
if not this.strategies

  peonStrategyUnits = [@gatherer]
  munchkinStrategyUnits = [@trash]
  tankHealerStrategyUnits = [@tank, @healer, @trash]
  healerStrategyUnits = [@healer]
  attackStrategyUnits = [@attack]
  attackHealerStrategyUnits = [@attack, @healer]
  doubleTrashStrategyUnits = [@trash, @trash]
  tripleTrashStrategyUnits = [@trash, @trash, @trash]
  trashHealerStrategyUnits = [
    @trash, @trash, @trash,
    @trash, @trash, @trash,
    @healer, @healer]

  this.strategies = []

  class Strategy
    constructor: (@units, @eval) ->

    evaluate: () ->
      @eval()

  peonStrategy = new Strategy peonStrategyUnits, () ->
    return numPeons < 2
  thirdPeonStrategy = new Strategy peonStrategyUnits () ->
    return numEnemyPeons >= 3
  trashStrategy = new Strategy trashStrategy () ->
    return true
  #doubleTrashStrategy doubleTrashStrategyUnits, () ->
  #    return getUnitByType(soldier, enemies)

  this.strategies.push peonStrategy
  this.strategies.push peonStrategy
  #this.strategies.push doubleTrashStrategy
  #this.strategies.push tankHealerStrategy
  #this.strategies.push trashHealerStrategy

  @defaultStrategy = trashStrategy


if numPeons is 1
  findAndMoveToItem peons[0], items
else if numPeons > 1
  #loop through all the items, finding top and bottom

  if not @myTopIndex?
    peonAbove = aboveOrBelow peons[0]

    @myTopIndex = if peonAbove > 0 then 1 else 0
  myTopIndex = @myTopIndex

  top = []
  bottom = []

  for item in items
    do(item) ->
      above = aboveOrBelow item
      top.push item if above >= 0
      bottom.push item if above < 0

  count = 0
  useTop = false
  for peon in peons
    do(peon) ->
      if count >= 2
        # send all later peons everywhere
        items = top.concat bottom
        items = findAndMoveToItem peon, items
      else
        #divide the first two between top and bottom
        useTop = if myTopIndex == count then true else false
        count++
        if useTop is true
          #base.say 'top'
          top = findAndMoveToItem peon, top
        else
          bottom = findAndMoveToItem peon, bottom

currentStrategy = null
totalCost = 0
usingDefault = false

# Determine if there is still a strategy left to use. If not, use default
###
if this.strategies.length > 0
    currentStrategy = (this.strategies.splice(0, 1))[0]
else
    currentStrategy = @defaultStrategy
    usingDefault = true
###

if not @building
  for s in @strategies
    do(s) ->
      totalCost = determineTotalCost s.units
      if base.gold >= totalCost and s.eval() == true
        currentStrategy = s
        break

if not currentStrategy?
  u = currentStrategy.units.slice()
  toBuild = u.splice(0, 1)
  @building = if u.length > 0 then u else null

  base.build toBuild if toBuild and toBuild != ''

# if we can start building the current strategy in full, do it
###
if base.gold >= totalCost
    toBuild = currentStrategy.splice(0, 1)
    base.build toBuild[0] if toBuild and toBuild[0] != ''

    this.strategies.unshift(currentStrategy) if currentStrategy.length > 0
else if not usingDefault
    this.strategies.unshift currentStrategy
    if not this.addedThirdPeon and numEnemyPeons > 2 and numPeons == 2
        this.strategies.unshift peonStrategy
        this.addedThirdPeon = true
###

currentStrategy = null












