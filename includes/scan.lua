--code for the scanning tool

collectables = {
    ---          line 1                       line 2
    ---     |                             |                              |             
    [001] = "test",
    [033] = "the ship you arrived on, it   landed after you ejected",
    [034] = "your ship deployed these      save points before you crashed",
    [069] = "the door is sealed. it is     decorated with the blue mineral",
    [071] = "the wall of the cave drips    with gooey green gunk",
    [074] = "the wall of the cave drips    with gooey green gunk",
    [076] = "the blue has completely       absorbed the moss of the cave",
    [102] = "mysterious blue mineral, it   has a hauntingly steady glow",
    [066] = "the blue has weakened this    rock",
    [114] = "the blue has seeped into the  rock and consumed it",
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


--prints dialogue and item descriptions to the screen
function print_desc(text)

    xoff = 2
    yoff = 110

    max_chars = 31

    last_space = 0 --position of last space in string

    p_line = 0 --print line

    --draw outline
    rect(camera_pos.x+xoff-1, camera_pos.y+yoff-1-1, camera_pos.x+xoff+(max_chars*4)+1, camera_pos.y+yoff+15+1, 8)
    rectfill(camera_pos.x+xoff, camera_pos.y+yoff-1, camera_pos.x+xoff+(max_chars*4), camera_pos.y+yoff+15, 0)

    --display text
    local i = 1
    while i < #text+1 do 

        if i == max_chars and p_line == 0 then
            p_line = 1
        end

        local x = camera_pos.x+xoff-3+(i*4)-(120*p_line)
        local y = camera_pos.y+yoff+(6*p_line)

        print(sub(text, i,i), x, y, 7)
      
        i += 1
    end
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
            local text = collectables[player.s_target]
            print_desc(text)
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
