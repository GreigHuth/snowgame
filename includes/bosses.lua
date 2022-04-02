
boss1 = {
    x = 7*8, 
    y = 9*8, 
    dy = 0,
    max_dy = 1,
    dx = 0,
    w = 16, --pixel width and height
    h = 16,
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

    update = function(self)

        self.dy += mid(0, self.dy+gravity, self.max_dy)

        if hit_solid(self.x, self.y+self.dy, 15, 15) == true then
            self.dy = 0
        end

        self.y += self.dy

        
            
    end

}