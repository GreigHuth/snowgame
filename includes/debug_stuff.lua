--archive of random debug code to stop main files geting clogged up
rotate_tes = {
    x = 72,
    y = 240,
    spr_n = 20,
    timer = 0,
    a_timer = 0,
    init = 0,
    
    draw = function(self)

        local xoff = 4*8
        local yoff = 1*8

        local xb = self.x + 4
        local yb = self.y + 4

        for i=0, 7, 1 do
            for j = 0, 7, 1 do

                --get colour
                local c = sget(xoff+i, yoff+j)
                    
                local newx,newy= rotate_pixel(self.x+i, self.y+j, -self.a_timer, xb, yb, false)
                printh("new:"..newx..","..newy)

                pset(newx, newy, c)
                pset(self.x, self.y, 0)
            end
        end
    
    end,

    update = function(self)
        self.timer += 1
        if self.timer == 5 then
            self.timer = 0
            self.a_timer += 90
        end
    end

    

}

--keep it around jic
if btnp(4) then
    ball = {
        x = player.x,
        y = player.y+3,
        c = 7,
        r = 0.1,
    
        dx = 2.5,
        dy = 0,
        orient = player.orient,
        update = function(self)

            if  self.orient then
                self.x -= self.dx
            else 
                self.x += self.dx
            end
        end,
    
        draw = function(self)
            circ(self.x, self.y, self.r, self.c)
        end
    
    }
    add(actors_d, ball)
    --player:draw_item(items.staff, 3, -1)
    player.state.atk = 1
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