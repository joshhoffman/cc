loop
#@say "test"
    enemies = @findEnemies()
    nearestEnemy = @findNearest enemies

    if @gold >= @costOf "soldier"
        @summon "soldier"
    else
        enemy = friend.findNearest enemies
        @attack enemy

    @move(@findNearest(@findItems()).pos)

    friends = @findFriends()
    for friend in friends
        @say friend
        enemy = friend.findNearest enemies
        @command(friend, "attack", enemy)
