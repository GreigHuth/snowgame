--Made By Gurg

player = {
        x = 5*8,
        y = 12*8,
        w = 3,
        h = 5,

        dx = 0,
        dy = 0,

        max_dx = 0.75,
        max_dy = 2,

        accel = 0.03,

        s_target = 0, --just a debugging thing

        sprites = {
            idle = 1,
            index = 1,
            run = {2,3},
            doublej = 14,           
        },

        spinjump = false, 

        noclip = false,

        orient = false, --true means facing left, false means facing right
                        --this seems strange but it simplifies sprite drawing code    
        animstep = 5,
        
        timers = {
            timer = 0,  --these need to be all merged or managed together in some way
            a_timer = 0,
            animtimer = 0
        },
        
        jmp_max = 1,
        states = {
            jmp = 1,
            scanning = false, 
            dead = false
        },

        --anchor point to ensure symmetry when drawing additonal things to player, like eye rays for the photo
        anchor ={
            x = 0,
            y = 0, 
            --updates position relavite to direction is facing and returns the absolute screen position 
            add = function(self, orient, a) 
                if orient then return self.x - a
                else return self.x + a
                end
            end
        },
      
}



-- returns true if player has line of sight with scan target, false otherwise
function los_detection()
end
--uncessesary for now
function player:init()
    self.sprites.index = 1
    self.states.scanning = false
end

hb_offset = 2 --offsets hitbox from absolute player position
function player:draw_hitbox()
    local hb_colour = 7
    rect(self.x+hb_offset, self.y, self.x+hb_offset+self.w, self.y+self.h, hb_colour)
end

--checks the 4 corners of the given box to see if ot overlaps with a block flagged as solid
function hit_solid(x, y, w ,h)

    x += hb_offset

    for i=x, x+w, w do
        --if pixel is both part of a solid sprite and not black then
        if fget(mget(i/8, y/8), 1) or fget(mget(i/8, (y+h)/8), 1) then
            return true
        end
    end

    return false
end 

function hit_head(x, y, w)

    x += hb_offset

    for i=x, x+w, w do
        --if pixel is both part of a solid sprite and not black then
        if fget(mget(i/8, y/8), 1) then
            return true
        end
    end

    return false
end 

--checks to see if the given box collides with any solid pixels
function pp_collision(x, y, w, h)

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
            if fget(mget(i/8, j/8), 1) then
                return true
            end
        
        end
    end

    --printh(c)      
end


--returns true if the player is standing on a sprite with flag
function player:standing_on(flag)
    return fget(mget(self.x/8, (self.y+8)/8), 7)
end

function player:rotate() 
    --DOES THE FANCY SPRITE ROTATIONS
    local xoff = 4*8
    local yoff = 1*8

    local xb = self.x + 4
    local yb = self.y + 4

    for i=0, 7, 1 do
        for j = 0, 7, 1 do
            if c != 0 then --ignore black squares when drawing player, 
                if self.orient == true then
                    --get colour
                    local c = sget(xoff+i+8, yoff+j)
                    local newx, newy= rotate_pixel(self.x+i, self.y+j, self.timers.a_timer, xb, yb, false)
                    pset(newx, newy, c)
                else 
                    local c = sget(xoff+i, yoff+j)
                    local newx, newy= rotate_pixel(self.x+i, self.y+j, -self.timers.a_timer, xb, yb, false)
                    pset(newx, newy, c)
                end
            end

        end
    end
end

function player:draw()
    --this block controls drawing jumping sprites
    if self.dy != 0 then 
        
        --this block can probably be ripped out and encapsulated in its own function
        if self.states.jmp == 0 and self.spinjump == true then
            player:rotate()

        elseif self.dy == 1 then
            spr(19, self.x, self.y, 1, 1, self.orient)
        else 
            spr(18, self.x, self.y, 1, 1, self.orient)
        end


    --this block controls drawing  running sprites
    elseif self.dx != 0 then --do run animation

        spr(self.sprites.run[self.sprites.index] ,self.x, self.y, 1, 1, self.orient) --draw body

        if self.timers.animtimer == 0 and abs(self.dx) >=self.max_dx*0.25 then 
            self.sprites.index += 1
            if self.sprites.index == (#self.sprites.run +1) then
                self.sprites.index = 1
            end
        end
        
    elseif btn(3) then --crouching
        spr(17,self.x, self.y, 1, 1, self.orient)

    else --reset running animation
        self.sprites.index = 1
        spr(self.sprites.idle ,self.x, self.y, 1, 1, self.orient)
    end


end


--update anchor point
function player:update_anchor()
    if self.orient then
        self.anchor.x = self.x + 3
        self.anchor.y = self.y + 4
    else
        self.anchor.x = self.x + 4
        self.anchor.y = self.y + 4
    end
end

--reset player to last checkpoint
function player:reset()
end

function player:stair_bump()
    local x = self.anchor:add(self.orient, 2)
    local y = self.anchor.y
    if pget(x, y) == 0 and ( pget(x, y+1) == 4 or pget(x, y+2) == 4) and abs(self.dx) > 0 and fget(mget(x/8, (y+1)/8), 1) then
        self.y -=1
        if not self.orient then
            self.x +=0.4
        else
            self.x-=0.4
        end
    end
end


function player:move()

    --player cant move and has completely different actions when taking a photo
    if self.states.photo == true then return end

    if self.noclip then
        if btn(0) then self.x -= 5
        elseif btn(1) then self.x += 5
        elseif btn(2) then self.y -= 5
        elseif btn(3) then self.y += 5
        end
        return
    end

    self:update_anchor()

    --cannot add horizontal movement when in the air
    accel_mod = 1
    if self.states.jmp < self.jmp_max then
        accel_mod = 0.25
    end

    --moving left
    if btn(0) then 
        self.orient = true
        self.dx -= self.accel*accel_mod
        self.dx = mid(0, self.dx, -self.max_dx)
    --moving right
    elseif btn(1) then 
        self.orient = false
        self.dx += self.accel*accel_mod
        self.dx = mid(0, self.dx, self.max_dx) 
    --handles decceleration 
    else
        self.dx = self.dx * 0.8
        if abs(self.dx) < 0.05 then
            self.dx = 0 
        end
    end


    self:stair_bump()

    --jumping
    --WIP 
    if btnp(2) and self.states.jmp > 0 then 
        self.dy = -1
        self.states.jmp -= 1
    end

    --gravity is weak on the way up and strong on the way down
    if self.dy < 0 then 
        self.dy += (gravity*0.25)
    else
        self.dy += gravity*0.5
        self.dy = mid(0, self.dy, self.max_dy)
    end
    
    
    

    --do basic collision when jumping, cba coding the pp proberly
    if self.dy < 0 then 
        if hit_head(self.x, self.y+self.dy, self.w) then
            self.dy = 0--if yes then dont let them update 
        end
    --floor collision
    elseif pp_collision(self.x, self.y+self.dy, self.w, self.h) then
        self.dy = 0--if yes then dont let them update 
        self.states.jmp = self.jmp_max
    end

    --wall collision
    if pp_collision(self.x+self.dx, self.y, self.w, self.h) then
        self.dx = 0
    end
    
    

    --oob detection
    if (self.x + self.dx) < 0 then self.dx = 0 end 

    --update player position
    self.x += self.dx
    self.y += self.dy
       
end


function player:update()

    self.timers.animtimer = (self.timers.animtimer + 1)%self.animstep

    player:move()


    self.timers.timer += 1
    if self.timers.timer == 3 then
        self.timers.timer = 0
        self.timers.a_timer += 90

        if self.timers.a_timer == 360 then 
            self.timers.a_timer = 0
        end
    end

    --toggle scan mode
    if btnp(5) then
        if self.states.scanning == false then
            self.states.scanning= true
        else
            self.states.scanning = false
        end
    end
end
