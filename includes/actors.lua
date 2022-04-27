--functions common to all actors in the game

--checks the 4 corners of the given box to see if ot overlaps with a block flagged as solid
function hit_solid(x, y, w ,h)
    local hb_offset = 2 --offsets hitbox from absolute player position
    x += hb_offset

    for i=x, x+w, w do
        --if pixel is both part of a solid sprite and not black then
        if fget(mget(i/8, y/8), 1) or fget(mget(i/8, (y+h)/8), flag.SOLID) then
            return true
        end
    end

    return false
end 


function hit_head(x, y, w)
    local hb_offset = 2 --offsets hitbox from absolute player position
    x += hb_offset

    for i=x, x+w, w do
        --if pixel is both part of a solid sprite and not black then
        if fget(mget(i/8, y/8), flag.SOLID) then
            return true
        end
    end

    return false
end 


--checks to see if the given box collides with any solid pixels
function pp_collision(x, y, w, h)
    local hb_offset = 2 --offsets hitbox from absolute player position
    y = flr(y)
    x += hb_offset
    local c = 0

    --if the layer of blocks underneath the player is 
    for i=x, x+w, 1 do
        if pget(i, y+6) == 0 then
            c+=1
        end
    end

    if c == 4 then return false end

    --this is innefficient af, program this the old way
    for i=x, x+w, 1 do
        for j=y, y+h, 1 do
            if fget(mget(i/8, j/8), flag.SOLID) then
                return true
            end
        
        end
    end

    --printh(c)      
end