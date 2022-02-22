--a draw function that will rotate
function draw_rotate(x, y, w, h, column, row, theta)
    local column = column*8
    local row = row*8

    local xb = x + w/2
    local yb = y + w/2


    for i=0, w, 1 do
        for j = 0, h, 1 do

            --get colour
            local c = sget(column+i, row+j)

            --ignore blacks
            if c != 0 then
                
                local new_x,new_y= rotate_pixel(x+i, y+j, theta, xb, yb, false)
                printh("new:"..new_x..","..new_y)

                --draw new colours
                pset(new_x, new_y, c)
            end
        end
    end

    printh("next")
end

testing = {
    x = 63,
    y = 63,
    w = 15, 
    h = 15,
    spr_n = 9,
    timer = 0,
    a_timer = 0,
    theta = -45,
    init = 0,
    
    draw = function(self) 
        draw_rotate(self.x, self.y, self.w, self.h, 9, 0, self.a_timer)
    end,

    update = function(self)
        self.timer += 1
        if self.timer == 30 then
            self.timer = 0
            self.a_timer += 45
        end
    end

    

}

dust_anim = {
    x = 0, 
    y = 0
}



 
--Made By Gurg

snow_class = {} --ghetto classes

--program dynamic weather
-- spawns above player
-- changes between rooms

--will add to randomness of the game

--maybe implement interfaces for particle effects?
function snow_init(xpos, ypos)
    add(snow_class, {
        xorigin = xpos,
        yorigin = ypos,
        x = xpos,
        y = ypos,
        c = 7,
        animtimer = 0,
        step = 10,
        sway = 5,
        sway_dir = 0 --direction to sway snow particle in, 0 is left, 1 is right
    })
    
end


function draw_snow()
    for snow in all(snow_class) do
        snow.animtimer = (frame_counter + 1)%snow.step
        pset(snow.x, snow.y, snow.c)
        if snow.animtimer == 0 then --this will return true every s frames
            snow.y += 1 --snow goes down

            if snow.sway > 0 then
                if snow.sway_dir == 0 then
                    snow.x -= 1
                    if abs(snow.xorigin - snow.x) >= snow.sway then
                        snow.sway_dir = 1
                    end
                else 
                    snow.x += 1
                    if abs(snow.xorigin - snow.x) >= snow.sway then
                        snow.sway_dir = 0
                    end
                end
                --if the snow hits something reset its position
                if hit_solid(snow.x, snow.y, 2, 2) then     
                    snow.x = snow.xorigin
                    snow.y = snow.yorigin
                end
            end
        end
    end
end