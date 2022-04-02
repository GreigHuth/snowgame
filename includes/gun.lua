--code do to tha shooty bangs

--track all the bullets on screen


gun={
    x = 0,
    y = 0
}
--bullet management system lel
--x, y, radius, colour, dx, dy
bms = {
    max_bullets = 10,
}

bullets = {
}

function bullet_draw(bullet)
    circ(bullet[1],bullet[2], bullet[3], 6)
end

--draw bullet
function bms:draw()
    foreach(bullets, bullet_draw)
    local cursor_x = stat(32)+camera_pos.x
    local cursor_y = stat(33)+camera_pos.y
    rect(cursor_x, cursor_y, cursor_x+2, cursor_y+2, 7)
end


function bms:update()

    if stat(34) == 1 then
        add_bullet()
    end

    rect(60, 60, 3, 3, 6)
end

--NEEDS OPTIMISED SEE SCAN.LUA LINE 151
function add_bullet()
    local cursor_x = stat(32)+camera_pos.x
    local cursor_y = stat(33)+camera_pos.y
    local bullet = {cursor_x, cursor_y, 1}
    add(bullets, bullet)
end
