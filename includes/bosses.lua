
boss1 = {
    x = 8* 8, 
    y = 6* 8, 
    dy = 0,
    max_dy = 5,
    dx = 0,
    w = 16, --pixel width and height
    h = 16,
    ft = 0,
    orient = true, --true is right, false is left
    sprites = {
        normal = {13, 14, 29, 30},
        enrage = {11, 12, 27, 28}
    },

    states = {
        enrage = false,
        in_air = true,
    },

    draw =  function(self)
        if not enrage then 
            spr(self.sprites.normal[1], self.x, self.y)
            spr(self.sprites.normal[2], self.x+8, self.y)
            spr(self.sprites.normal[3], self.x, self.y+8)
            spr(self.sprites.normal[4], self.x+8, self.y+8)
        end
    end,

    
    update = function(self)

        self.ft = (self.ft + 1)%stat(8)
 
        

        if (30 < self.ft) and (self.ft < 40) and self.in_air == false then
            self.dy = -1
            self.in_air = true
        end

        g_modifier = 0.25
        --apply gravity
        self.dy += gravity*g_modifier

        if self.dy >= 0 then 
            self.dy = mid(0, self.dy, self.max_dy)--only clamp speed on the way down
        end
        --do collision        
        if hit_solid(self.x, self.y+self.dy, 15, 15) == true then
            self.dy = 0
            self.in_air = false
        end

        --update position
        self.y += self.dy   
        self.x += self.dx
    end


}


target = {
    x=4*8,
    y=6*8,
    sprite = 9,
    ft = 0, --frame timer
    draw = function(self)
        spr(self.sprite, self.x, self.y)
    end, 
    update = function(self)
        ft = ft+1%stat(8)  
    end 

}