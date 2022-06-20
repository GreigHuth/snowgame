--Made By Gurg

player = {
        --position
        x = 11*8,
        y = 14*8,

        --width and height
        w = 4,
        h = 6,

        hb_xoff = 2,

        --velocity
        dx = 0,
        dy = 0,

        max_dx = 0.75,
        max_dy = 2,

        --number of frames of airtime
        airtime = 0,
        max_airtime = 30,

        sensors = {
            bl = {2,5},
            br = {5,5},
        },

        accel = 0.03, --acceleration in pixels per frame, i playtested and found this to be best

        

        --scan target
        s_target = 0,

        --spr numbers for all necessary sprites
        sprites = {
            idle = 1,
            index = 1,
            run = {2,3},
            doublej = 14,
        },

        --enable spinjump
        spinjump = false,


        --true means facing left, false means facing right, helps simplify sprite drawing script
        orient = false,


        timers = {
            timer = 0,  --these need to be all merged or managed together in some way
            a_timer = 0,
            animtimer = 0
        },


        states = {
            in_air = true,
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
        }


}



function player:init()
    self.sprites.index = 1
    self.states.scanning = false
    self.input = false
end


function player:draw_hitbox()
    local hb_offset = 2 --offsets hitbox from absolute player position
    local hb_colour = 7
    rect(self.x+hb_offset, self.y, self.x+hb_offset+self.w, self.y+self.h, hb_colour)
end


--returns true if the player is standing on a sprite with flag
function player:standing_on(flag)
    local x = self.x +self.hb_offset
    local y = self.y + self.h+1
    for i=x, x+self.w, 1 do
        if fget(mget(i/8, y/8), flag) then return true end
    end
    return false
end


function player:rotate()
    --DOES THE FANCY SPRITE ROTATIONS
    local xoff = 4*8
    local yoff = 1*8

    local xb = self.x + 4
    local yb = self.y + 4

    for i=0, 7, 1 do
        for j = 0, 7, 1 do
            if c ~= 0 then --ignore black squares when drawing player,
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
    if self.dy ~= 0 then
        --this block can probably be ripped out and encapsulated in its own function
        if self.states.jmp == 0 and self.spinjump == true then
            player:rotate()
        elseif self.dy > 0.5 then
            spr(19, self.x, self.y, 1, 1, self.orient)
        else
            spr(18, self.x, self.y, 1, 1, self.orient)
        end


    --this block controls drawing  running sprites
    elseif self.dx ~= 0 then --do run animation

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


function player:drawHUD()
    --draw airtime meter
    local camx, camy = get_camera_pos()
    local gauge_l = 20
    local airtime_left = 1 - (self.airtime/self.max_airtime)
    color(10)
    rectfill(camx+100, camy+10, camx+100+(gauge_l*airtime_left), camy+15)
    color(7)
    rect(camx+100, camy+10, camx+100+gauge_l, camy+15)
end


function player:refill_airtime()
    self.airtime -= 4
    self.airtime = mid(0, self.airtime, self.max_airtime)
end

function player:handle_input()

    local p = 1 --player
    local accel_mod = 1

    --godmode
    noclip = false
    if noclip then
        if btnp(0, p) then self.x -= 1
        elseif btnp(1, p) then self.x += 1
        elseif btnp(2, p) then self.y -= 1
        elseif btnp(3, p) then self.y += 1
        end

        return
    end

    --moving left
    if btn(0, p) then
        self.dx -= self.accel*accel_mod
        self.dx = mid(0, self.dx, -self.max_dx)
        self.orient = true

    --moving right
    elseif btn(1, p) then
        self.dx += self.accel*accel_mod
        self.dx = mid(0, self.dx, self.max_dx)
        self.orient = false

    --handles decceleration
    else
        self.dx = self.dx * 0.8
        if abs(self.dx) < 0.05 then
            self.dx = 0
        end
    end


    --do jump
    if btn(2, p) then
        local jmp_v = -0.75
        if self.airtime < self.max_airtime then
            self.airtime += 1
            self.dy = jmp_v
        end
    end


    --apply gravity
    self.dy += gravity

    --check basic collision
    if hit_tile(TILE_FLAG.SOLID, self.x+self.dx+self.hb_xoff, self.y, self.w, self.h) then
        self.dx = 0
    end
    if hit_tile(TILE_FLAG.SOLID, self.x+self.hb_xoff, self.y+self.dy, self.w, self.h) then
        self.dy = 0
        self:refill_airtime()
    end


    --check for slope collision
    if hit_tile(TILE_FLAG.SLOPE, self.x+self.dx+self.hb_xoff, self.y+self.dy, self.w, self.h) then


        self.dx = self.dx * 0.95--slow down player on stairs just a bit

        local yoff = 0

        if self.dx <= 0 then
            yoff = slope_collision(self.x+self.sensors.bl[1]+self.dx, self.y+self.sensors.bl[2]+self.dy)--moving left
        else
            yoff = slope_collision(self.x+self.sensors.br[1]+self.dx, self.y+self.sensors.br[2]+self.dy)--moving right
        end


        if yoff == 0 then
            if self.dy > 0 then
                self.dy = 0
                self:refill_airtime()
            end

        elseif yoff > 0 then
            --if yoff > 2 then yoff = 0 end
            self.y -= yoff
            self:refill_airtime()
        end

    end

    
    self.y += self.dy
    self.x += self.dx

end


function player:update()

    animstep = 5--how often to tick over to next frame of animation, used when drawing run cycle

    --update frame timer
    self.timers.animtimer = (self.timers.animtimer + 1)%animstep

    self:handle_input()


    --anchor is so the scanning line knows where to attach itself to the player
    self:update_anchor()


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
