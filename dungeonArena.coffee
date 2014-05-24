friends = @getFriends()
enemies = @getEnemies()
return if enemies.length == 0
enemy = @getNearest enemies
friend = @getNearest friends

hero = this

getLowHealth = (friendsToSearch) ->
    count = 0
    ret = null
    for f in friends
        do (f) ->
            #hero.say 'health ' + f.health + 'max ' + f.maxHealth
            count++
            if f.health < f.maxHealth
                ret = f
    #hero.say count if count == friendsToSearch.length
    return ret

getUnitByType = (unitType, unitsToSearch) ->
    ret = []
    for entry in unitsToSearch
        do(entry) ->
            ret.push(entry) if entry.type is unitType
    return ret

friendToHeal = getLowHealth friends
archer = getUnitByType 'archer', friends?
archer = archer?[0]

if enemy and @canCast 'slow', enemy
    @castSlow enemy
else if friendToHeal and @canCast 'regen', friendToHeal
    @castRegen friendToHeal
else if archer and @canCast 'haste', archer
    @castHaste archer
else
    @attack enemy

#@castSlow enemy if @canCast 'slow', enemy
#@castRegen friend if @canCast 'regen', friend
#@castHaste friend if @canCast 'haste', friend
#@attack enemy
###
// The Librarian is a spellcaster with a fireball attack
// plus three useful spells: 'slow', 'regen', and 'haste'.
// Slow makes a target move and attack at half speed for 5s.
// Regen makes a target heal 10 hp/s for 10s.
// Haste speeds up a target by 4x for 5s, once per match.

var friends = this.getFriends();
var enemies = this.getEnemies();
if (enemies.length === 0) return;  // Chill if all enemies are dead.
var enemy = this.getNearest(enemies);
var friend = this.getNearest(friends);

// Which one do you do at any given time? Only the last called action happens.
//if(this.canCast('slow', enemy)) this.castSlow(enemy);
//if(this.canCast('regen', friend)) this.castRegen(friend);
//if(this.canCast('haste', friend)) this.castHaste(friend);
//this.attack(enemy);

// You can also command your troops with this.say():
//this.say("Defend!", {targetPos: {x: 30, y: 30}}));
//this.say("Attack!", {target: enemy});
//this.say("Move!", {targetPos: {x: 50, y: 40});
###