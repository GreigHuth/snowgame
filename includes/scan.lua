--code for the scanning tool

collectables = {
    ---                                                                                     | max length             
    [001] = "test",
    [033] = "the ship you arrived on, it landed after you ejected",
    [034] = "your ship deployed these save points before you crashed",
    [069] = "the door is sealed. it is decorated with the blue mineral",
    [071] = "the cavern wall drips with gooey green gunk.",
    [074] = "the cavern wall drips with gooey green gunk.",
    [076] = "the blue has completely absorbed the moss of the cave",
    [102] = "mysterious blue mineral, it has a hauntingly steady glow",
    [066] = "the blue has weakened this rock",
    [114] = "the blue has seeped into the rock and consumed it",
    [092] = "this contraption is extracting the blue ore. its loud"
 }

scan_rect = {
    x = 0,
    y = 0,
    w = 16,

    scanline = { --scanline for scanning tool
        x = 0,
        y = 0,
        w = 16,
        yoff = 0,
        c = 11
    },
}

--struct to control printing stuff
p_control = {
    
    spr = 0, --sprite we get the text from
    pos = 0, --position in the string
    
    anim = {
        s = 0, -- keep track of timing
        t = 10 -- how often we update 
    },

    pline = 0
    
    
}


function scan_rect:scan()
    for i=self.x, self.x+15, 1 do
        for j=self.y, self.y+15, 1 do

            local s = mget(i/8, j/8)
            if fget(s, 6) == true then
                return s
            end
        end
    end

    return -1
end


--works backwards from index and returns the postion of the closest space to the index
--returns the index if there is a space and -1 otherwise
function find_space(start, stop, text)


    while stop > start do

        if sub(text, stop, stop) ==  " " then 
            return stop
        end

        stop -= 1

    end
    
    return -1
end

--prints dialogue and item descriptions to the screen
function print_desc(spr)

    text = collectables[spr]

    xoff = 1
    yoff = 100

    max_chars = 30

    last_space = 0 --position of last space in string

    p_line = 0 --print line

    --draw outline
    
    rectfill(camera_pos.x+xoff, camera_pos.y+yoff, camera_pos.x+xoff+(31*4)+2, camera_pos.y+yoff+((6*3)+3), 0)
    rect(camera_pos.x+xoff, camera_pos.y+yoff, camera_pos.x+xoff+(31*4)+2, camera_pos.y+yoff+(6*3)+3, 8)

    last_space = find_space(0, 31, text)
    last_space2 = find_space(32, 60, text)

    local x = camera_pos.x+xoff+2
    local y = camera_pos.y+yoff+2

    print(sub(text, 0, last_space), x, y, 7)
    print(sub(text, last_space+1, last_space2), x, y+6, 7)
    --print(sub(text, last_space2+1, 80), x, y+12, 7)

end


holding = 0
function scan_rect:draw()
        
    local x1 = player.anchor:add(player.orient, -1) --set eye positions
    local x2 = player.anchor:add(player.orient, 1)
    local y =  player.anchor.y - 3
    
    line(x1, y, self.x, self.y+15, 10)
    line(x2, y, self.x+15, self.y+15, 10)

    
    rect(self.x, self.y, self.x+15, self.y+15, 10)



    if stat(34) == 1 then
        
        local y = self.scanline.y+self.scanline.yoff
        line(self.scanline.x, y, self.scanline.x+15, y, self.scanline.c)
        self.scanline.yoff += 0.5

        player.s_target = self:scan()

        
        if player.s_target  != -1 then
            spr(103, self.x, self.y-8) --draw "!" if target is scannable
            print_desc(player.s_target)
        end

        if self.scanline.yoff == 15 then
                self.scanline.yoff = 0 
        end

    else 
        self.scanline.yoff = 0
    end
    
end


--update position of scan reticule, regardless if its on screen or not
function scan_rect:update()
    poke(0x5f2d, 1)
    local mouse_x = stat(32)
    local mouse_y = stat(33)

    self.x = mouse_x+camera_pos.x
    self.y = mouse_y+camera_pos.y

    self.scanline.x = self.x 
    self.scanline.y = self.y

end
