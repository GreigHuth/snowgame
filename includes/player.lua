--Made By Gurg

player = {
        x = 5*8,
        y = 14*8,
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

        orient = false, --true means facing left, false means facing right, helps simplify sprite drawing script
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
            gun = true, --start with gun
            dead = false,
            crouching = false
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



function player:init()
    self.sprites.index = 1
    self.states.scanning = false
end



function player:draw_hitbox()
    local hb_offset = 2 --offsets hitbox from absolute player position
    local hb_colour = 7
    rect(self.x+hb_offset, self.y, self.x+hb_offset+self.w, self.y+self.h, hb_colour)
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
        elseif self.dy > 0.5 then
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
        

    elseif btn(3, 1) then --crouching
        spr(17,self.x, self.y, 1, 1, self.orient)
    else --reset running animation
        self.sprites.index = 1
        spr(self.sprites.idle ,self.x, self.y, 1, 1, self.orient)
    end


   


end


--update anchor point, for drawing things on the player
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

    --work out if were trying to walk up stairs or not, stairs are diagonal lines with the colour 4, see sprites 101, 117
    --MAGIC NUMBERS BAD
    if pget(x, y) == 0 and ( pget(x, y+1) == 4 or pget(x, y+2) == 4) and abs(self.dx) > 0 and fget(mget(x/8, (y+1)/8), flag.SOLID) then
        self.y -=1

        if not self.orient then--depending on which way your facing, bump the player in that direction
            self.x +=0.4
        else
            self.x-=0.4
        end
    end
end


--the following two functions handle x and y movement respectively


function player:handle_x_movement()

    local p = 1 --player
    
    --moving left
    if btn(0, p) then 
        self.orient = true
        self.dx -= self.accel*accel_mod
        self.dx = mid(0, self.dx, -self.max_dx)

    --moving right
    elseif btn(1, p) then 
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
end

--as well as player input, this function also applies gravity to the player
function player:handle_y_movement()
    
    local p = 1 --player

    --jumping
    if btnp(2, p) and self.states.jmp > 0 then
        local jmp_strength = 1.25
        self.dy = -jmp_strength
        self.states.jmp -= 1
    end

    --gravity is weak on the way up and stronger on the way down
    if self.dy < 0 then 
        self.dy += (gravity*0.25)
    else
        self.dy += gravity*0.5
        self.dy = mid(0, self.dy, self.max_dy)
    end
end


function player:handle_collision()
    
    --check head collision while jumping so you dont get stuck
    if self.dy < 0 then 
        if hit_head(self.x, self.y+self.dy, self.w) then
            self.dy = 0--if yes then dont let them update 
        end
     
    --NOT OPTIMISED
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

end


function player:move()

    local p = 1 --player

    --godmode
    if self.noclip then
        if btn(0, p) then self.x -= 5
        elseif btn(1, p) then self.x += 5
        elseif btn(2, p) then self.y -= 5
        elseif btn(3, p) then self.y += 5
        end
        return
    end

    --anchor is so the scanning line knows where to attach itself to the player
    self:update_anchor()

    
    accel_mod = 1 --acceleration modifier 

    if self.states.jmp < self.jmp_max then --dont allow player to add horizontal speed in the air
        accel_mod = 0.25
    end

    self:handle_x_movement()

    --allows player to climb up stairs
    self:stair_bump()

    self:handle_y_movement()  

    --collision comes at the end to check the move the player wants to make is  a legal move
    self:handle_collision()


    --finally, update player position after youve worked out if its making a "legal" move
    self.x += self.dx
    self.y += self.dy
       
end


function player:update()

    --update frame timer
    self.timers.animtimer = (self.timers.animtimer + 1)%self.animstep

    self:move()

    -- this code is for doing the spinning animation, not needed right now
    --self.timers.timer += 1
    --if self.timers.timer == 3 then
    --    self.timers.timer = 0
    --    self.timers.a_timer += 90

    --    if self.timers.a_timer == 360 then 
    --        self.timers.a_timer = 0
    --    end
    --end


    --the code that actually does the shooting and scanning is in gun.lua and scan.lua respectively
    
    if btnp(4) and self.states.scanning == false then --toggle scan mode
            self.states.gun = false
            self.states.scanning = true
    elseif btnp(4) and self.states.scanning == true then
            self.states.scanning = false
            self.states.gun = true
    end
    
end
