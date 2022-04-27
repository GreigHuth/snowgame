
boss1 = {
    x = 41* 8, 
    y = 6* 8, 
    dy = 0,
    max_dy = 1,
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
        enrage = false 
    },

    draw =  function(self)
        if not enrage then 
            spr(self.sprites.normal[1], self.x, self.y)
            spr(self.sprites.normal[2], self.x+8, self.y)
            spr(self.sprites.normal[3], self.x, self.y+8)
            spr(self.sprites.normal[4], self.x+8, self.y+8)
        end
    end,

    move = function(self)
    end,
    
    update = function(self)

        self.dy += mid(0, self.dy+gravity, self.max_dy) --apply gravity

        --do collision        
        if hit_solid(self.x, self.y+self.dy, 15, 15) == true then
            self.dy = 0
        end

        --update position
        self.y += self.dy   
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