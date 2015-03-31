@summon "artillery"

loop
#@say "test"
    enemies = @findEnemies()
    nearestEnemy = @findNearest enemies

    if @gold >= @costOf("archer") && @findFriends().length % 2 == 0
        @summon "archer"
    else if @gold >= @costOf("soldier") * 1.5
        @summon "soldier"
    else
        #enemy = friend.findNearest enemies
        #if @canCast "drain-life", enemy
        #    @cast "drain-life", enemy
        if @canCast "goldstorm"
            @cast "goldstorm"
    #    @attack enemy

    @move(@findNearest(@findItems()).pos)

    friends = @findFriends()
    for friend in friends
        enemy = friend.findNearest enemies
        @command(friend, "attack", enemy)
#do (friend) ->
#@say "test2"

#@command(friend,"attack",friend.@findNearest(enemies))
