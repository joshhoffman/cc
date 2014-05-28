###
// This code runs once per frame. Build units and command peons!
// Destroy the human base within 180 seconds.
// Run over 4000 statements per call and chooseAction will run less often.
// Check out the green Guide button at the top for more info.
###

# TODO: Check the closest coin location for enemy peons. If one of my peons is closer
#  send him after that coin to block the enemy from picking it up

testsEnabled = true

base = this

determineGoldCost = (units) ->
    totalCost = 0
    for e in units
        totalCost += base.buildables[e]?.goldCost
    return totalCost

removeFromArray = (obj, arr) ->
    count = 0
    @arr = arr
    arr = for item in arr
        if item.pos.x is obj.pos.x and item.pos.y is obj.pos.y
            @arr.slice(count)
            count++
            #break
    return @arr

# This function is cleaner than the old way, but it seems to crash the editor
###
removeFromArray = (obj, arr) ->
    return arr.filter (x) ->
        x.pos.x is not obj.pos.x and x.pos.y is not obj.pos.y
###

getUnitByType = (unitType, unitsToSearch) ->
    ret = []
    #ret.push t for t in unitsToSearch when entry.type is unitType
    for entry in unitsToSearch
        ret.push(entry) if entry.type is unitType
    return ret

isTargeted = (gatherers, item) ->
    for gatherer in gatherers
        if gatherer.targetPos?
            if gatherer.targetPos.x is item.pos.x
                if gatherer.targetPos.y is item.pos.y
                    base.say 'true'
                    return true
    return false

pruneItems = (myGatherers, enemyGatherers, itemsToSearch) ->
    ret = []
    for item in itemsToSearch
        if isTargeted(myGatherers, item) is false
            if isTargeted(enemyGatherers, item) is false
                if item.bountyGold > 1
                    ret.push item
    return ret

findClosestUnit = (targetUnit, unitsToSearch) ->
    min = 9001
    ret = null
    for entry in unitsToSearch
        dist = targetUnit.distance entry
        if dist <= min
            min = dist
            ret = entry
    return ret

sign = (x) ->
    return (x > 0) - (x < 0)

findAndMoveToItem = (peon, itemsToSearch) ->
    item = peon.getNearest itemsToSearch
    if item
        base.command peon, 'move', item.pos
        #return removeFromArray(item, itemsToSearch)
    return itemsToSearch


getStrategy = (strats) ->
    ret = null
    for s in strats
        totalCost = determineGoldCost s.getUnitArray()
        if s.evaluateCondition(base) == true
            # if we have a strategy we need to use, but not enough gold
            # then stop searching
            if base.gold >= totalCost
                ret = s.getUnitArray()
            break
    return ret

aboveOrBelow = (item) ->
    return sign((85)*(item.pos.y) - (75)*(item.pos.x))

if not @strategies
    ogres = false
    if ogres is true
        @gatherer = 'peon'
        @healer = 'shaman'
        @tank = 'ogre'
        @trash = 'munchkin'
        @attack = 'fangrider'

        @enemyGatherer = 'peasant'
        @enemyTrash = 'soldier'
    else
        @gatherer = 'peasant'
        @healer = 'librarian'
        @tank = 'knight'
        @trash = 'soldier'
        @attack = 'griffin-rider'

        @enemyGatherer = 'peon'
        @enemyTrash = 'munchkin'

items = base.getItems()
peons = base.getByType @gatherer
enemyPeons = base.getByType @enemyGatherer
enemies = base.getEnemies()

items = pruneItems [], enemyPeons, items

numPeons = peons.length
numEnemyPeons = enemyPeons.length

base.numPeons = numPeons
base.numEnemyPeons = numEnemyPeons

###
var gatherer = 'peasant';
var healer = 'librarian';
var tank = 'knight';
var trash = 'soldier';
var attack = 'griffin-rider';

enemyGatherer = 'peon'
###



# Setup strategies

if not @strategies
    peonStrategyUnits = []
    trashStrategyUnits = [@trash]
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

    peonStrategyUnits.push @gatherer

    @strategies = []

    class Strategy
        constructor: (@units, @evalFunc) ->

        evaluateCondition: (nbase) ->
            return @evalFunc(nbase)

        getUnitArray: () ->
            return @units.slice()

    # TODO: functions are closures. Need to pass them in values...
    peonStrategy = new Strategy peonStrategyUnits, (lbase) ->
        return lbase.numPeons < 2
    thirdPeonStrategy = new Strategy peonStrategyUnits, (lbase) ->
        return lbase.numEnemyPeons >= 3 and lbase.numPeons < 3
    trashStrategy = new Strategy trashStrategyUnits, (lbase) ->
        return lbase.numPeons >= 2
    doubleTrashStrategy = new Strategy doubleTrashStrategyUnits, (lbase) ->
        return lbase.numPeons >= 2

    @strategies.push peonStrategy
    @strategies.push thirdPeonStrategy
    #@strategies.push trashStrategy
    #this.strategies.push peonStrategy
    this.strategies.push doubleTrashStrategy
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
        above = aboveOrBelow item
        top.push item if above >= 0
        bottom.push item if above < 0

    count = 0
    useTop = false
    for peon in peons
        if count >= 2
            # send all later peons everywhere
            # items = top.concat bottom
            items = pruneItems peons.slice().splice(0, 2), [], items
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

totalCost = 0

# Determine if there is still a strategy left to use. If not, use default
###
if this.strategies.length > 0
    currentStrategy = (this.strategies.splice(0, 1))[0]
else
    currentStrategy = @defaultStrategy
    usingDefault = true
###

if not @building or @building == null
    @currentStrategy = getStrategy @strategies

if @currentStrategy != null
    toBuild = @currentStrategy.splice(0, 1)
    toBuild = toBuild[0] if toBuild
    @building = if @currentStrategy.length > 0 then @currentStrategy else null

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










