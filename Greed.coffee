###
// This code runs once per frame. Build units and command peons!
// Destroy the human base within 180 seconds.
// Run over 4000 statements per call and chooseAction will run less often.
// Check out the green Guide button at the top for more info.
###

# -----------------------------------
# CODE IS COMPILED FROM COFFEESCRIPT
# -----------------------------------

# TODO: Check the closest coin location for enemy peons. If one of my peons is closer
#  send him after that coin to block the enemy from picking it up

base = this
base.myTime = base.now()

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


getTargeted = (gatherers, item) ->
    for gatherer in gatherers
        if gatherer.targetPos?
            if gatherer.targetPos.x is item.pos.x
                if gatherer.targetPos.y is item.pos.y
                    return gatherer
    return null

isTargeted = (gatherers, item) ->
    return getTargeted(gatherers, item) is not null

pruneItems = (myGatherers, enemyGatherers, itemsToSearch) ->
    ret = []
    for item in itemsToSearch
        for myGatherer in myGatherers
            targeted = getTargeted(enemyGatherers, item)
            if not targeted? or targeted.distance(item) > myGatherer.distance(item)
                #if item.bountyGold > 1
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

determineGoldCost = (units) ->
    totalCost = 0
    for e in units
        totalCost += base.buildables[e]?.goldCost
    return totalCost

getStrategy = (strats) ->
    ret = null
    for s in strats
        totalCost = determineGoldCost s.getUnitArray()
        if s.evaluateCondition(base) == true
            # if we have a strategy we need to use, but not enough gold
            # then stop searching
            if base.gold >= totalCost
                #base.say s.getMyName()
                ret = s.getUnitArray()
            break
    return ret

aboveOrBelow = (item) ->
    return sign((85)*(item.pos.y) - (75)*(item.pos.x))

# Set up some constants
if not @strategies
    @xMid = 42
    @yMid = 32

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
friends = base.getFriends()

items = pruneItems peons, enemyPeons, items

base.numPeons = peons.length
base.numEnemyPeons = enemyPeons.length

base.numFriends = friends.length - base.numPeons
base.numEnemies = enemies.length - base.numEnemyPeons

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
    peonStrategyUnits = [@gatherer]
    trashStrategyUnits = [@trash]
    tankHealerStrategyUnits = [@tank, @healer, @trash]
    healerStrategyUnits = [@healer]
    attackStrategyUnits = [@attack]
    attackHealerStrategyUnits = [@attack, @healer]
    doubleTrashStrategyUnits = [@trash, @trash]
    tripleTrashStrategyUnits = [@trash, @trash, @trash]
    trashHealerStrategyUnits = [
        @tank, @tank, @trash,
        @trash, @trash, @trash, @trash,
        @attack, @healer, @healer]
    ballerStrategyUnits = [
        @tank, @tank, @tank,
        @trash, @trash, @trash,
        @trash, @trash, @trash,
        @trash, @trash, @attack,
        @healer, @healer, @healer
        @healer, @healer, @healer
    ]

    @strategies = []

    class Strategy
        constructor: (@units, @myName, @evalFunc) ->

        evaluateCondition: (nbase) ->
            return @evalFunc(nbase)

        getUnitArray: () ->
            return @units.slice()

        getMyName: () ->
            return @myName

    peonStrategy = new Strategy peonStrategyUnits, "peon", (lbase) ->
        return lbase.numPeons < 2
    thirdPeonStrategy = new Strategy peonStrategyUnits, "third peon", (lbase) ->
        return lbase.numEnemyPeons >= 3 and lbase.numPeons < 3
    fourthPeonStrategy = new Strategy peonStrategyUnits, "fourth peon", (lbase) ->
        return lbase.numEnemyPeons >= 4 and lbase.numPeons < 4
    ballerStrategy = new Strategy ballerStrategyUnits, "baller", (lbase) ->
        return lbase.numEnemies is 0 and lbase.numFriends is 0 and lbase.myTime > 90.0
    trashStrategy = new Strategy trashStrategyUnits, "trash", (lbase) ->
        return lbase.numPeons >= 2
    doubleTrashStrategy = new Strategy doubleTrashStrategyUnits, "double trash", (lbase) ->
        return lbase.numPeons >= 2 and lbase.numEnemies > 1
    trashHealerStrategy = new Strategy trashHealerStrategyUnits, "trash healer", (lbase) ->
        return 5 < lbase.numEnemies < 9 and lbase.myTime > 75.0 and lbase.myTime < 90.0
    tankHealerStrategy = new Strategy tankHealerStrategyUnits, "tank healer", (lbase) ->
        return lbase.numEnemies >= 3 and lbase.numEnemies < 6
    attackStrategy = new Strategy attackStrategyUnits, "attack", (lbase) ->
        return lbase.numFriends >= 5
    attackHealerStrategy = new Strategy attackHealerStrategyUnits, "attack healer", (lbase) ->
        return lbase.numFriends >= 8

    @strategies.push peonStrategy
    @strategies.push thirdPeonStrategy
    @strategies.push fourthPeonStrategy
    @strategies.push ballerStrategy
    #this.strategies.push peonStrategy
    @strategies.push attackHealerStrategy
    @strategies.push attackStrategy
    @strategies.push trashHealerStrategy
    @strategies.push tankHealerStrategy
    @strategies.push doubleTrashStrategy


if @numPeons is 1
    findAndMoveToItem peons[0], items
else if @numPeons > 1 and @numPeons < 4
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
            #items = pruneItems peons.slice().splice(0, count), [], items
            items = findAndMoveToItem peon, items
            count++
        else
            #divide the first two between top and bottom
            useTop = if myTopIndex == count then true else false
            count++
            if useTop is true
                #base.say 'top'
                top = findAndMoveToItem peon, top
            else
                bottom = findAndMoveToItem peon, bottom
else #numPeons >= 4
    topRight = []
    bottomRight = []
    topLeft = []
    bottomLeft = []
    for item in items
        if item.pos.x <= @xMid and item.pos.y <= @yMid
            bottomLeft.push item
        else if item.pos.x >= @xMid and item.pos.y <= @yMid
            bottomRight.push item
        else if item.pos.x <= @xMid and item.pos.y >= @yMid
            topLeft.push item
        else if item.pos.x >= @xMid and item.pos.y >= @yMid
            topRight.push item
    itemSet = [topRight, topLeft, bottomLeft, bottomRight]

    count = 0
    for peon in peons
        findAndMoveToItem peon, itemSet[count]
        count++

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










