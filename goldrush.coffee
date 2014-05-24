getNearest = (itemsToSearch) ->
    nearest = 9001
    nearestItem = null
    #@say itemsToSearch.length
    #this.say 'test2'
    if itemsToSearch? or itemsToSearch.length == 0
        this.say 'null2' if itemsToSearch?
        return null
    @say 'test'
    for e in itemsToSearch
        do (e) ->
            dist = @distance(e)
            if dist < nearest and e.bountyGold > 4
                nearest = dist
                nearestItem = e
    return nearestItem

dude = this
items2 = this.getItems()
#this.say items.length
this.say 'null' if not items2?
#items = getNearest items2 if items2?
items = @getItems()
nearest = 9001
nearestItem = null
for e in items
    do (e) ->
        dist = dude.distance(e)
        if dist < nearest and e.bountyGold > 1
            nearest = dist
            nearestItem = e
if nearestItem and items?.length > 0
    this.move(nearestItem.pos)
###
// This code runs once per frame. Choose where to move to grab gold!
// First player to 150 gold wins.

// This is an example of grabbing the 0th coin from the items array.
var items = this.getItems();
if (items[0]) {
    this.move(items[0].pos);
} else {
    this.moveXY(18, 36);
}


// You can surely pick a better coin using the methods below.
// Click on a coin to see its API.
###