--functions common to all actors in the game


--returns the position relative to the bottom left of the tile x,y is in
function tile_height(x, y)
    return (flr(x)%8)+1, 8-(flr(y))%8
end


--checks to see if given box intersects a tile with the given flag
--returns true if it does intersect and false otherwise
function hit_tile(flag, x, y, w ,h)
    
    --need to offset w and h
    for i=x, x+w-1, w-1 do
        if fget(mget(i/8, y/8), flag) or fget(mget(i/8, (y+h-1)/8), flag) then
            return true
        end
    end
    return false
end


--returns the map cell containing the given x,y position
function get_cell(x, y)
    return flr(x/8), flr(y/8)
end

--does the slope collision
--the x and y given with typicall refer to a sensor on an actor in the game
--the function returns how much the actor needs to be moved up by to no longer be
-- colliding with the stairs
function slope_collision(x, y)

    --work out how high above the slope the coordinate it
    local tilex, tiley = tile_height(x, y)

    --retrieve required heightmap
    local local_hm = heightmap[mget(x/8, y/8)]

    if local_hm then --ignore tiles that dont have heightmap
        local step_h = local_hm[tilex]--get height of step above where he are=
        return (step_h - tiley) + 1 --move actor up this much
    end

    return 0

end


--general purpose gravity function
function apply_gravity(dy)
    return dy + gravity
end




