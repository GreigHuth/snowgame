camera_pos = {
    x = 0, 
    y = 0
}

function get_camera_pos()

    local camera_pos = {} 
    camera_pos[0] = peek2(0x5f28) -- x 
    camera_pos[1] = peek2(0x5f2a) -- y 
    return camera_pos
end

function camera_init()
end

--updates the cameras position, arguments are how much to offset the position by
function update_camera1()

    local x = player.x+2
    if (x - camera_pos.x) > 128 then
        camera_pos.x += 128
    elseif (x - camera_pos.x) < 0 then
        camera_pos.x -= 128
    end

    if (player.y - camera_pos.y) > 128 then
        camera_pos.y += 120
    elseif (player.y - camera_pos.y) < 0 then
        camera_pos.y -= 120
    end

    camera(camera_pos.x, camera_pos.y)
end

function update_camera()

    if player.x - camera_pos.x > 70 then 
        camera_pos.x += 1
    elseif player.x - camera_pos.x < 54 then 
        camera_pos.x -= 1
    end

    if player.y - camera_pos.y > 90 then 
        camera_pos.y += 1.25
    elseif player.y - camera_pos.y < 40 then 
        camera_pos.y -= 1.25
    end

    if camera_pos.x < 0 then camera_pos.x = 0 end
    if camera_pos.y < 0 then camera_pos.y = 0 end

    camera(camera_pos.x, camera_pos.y)
end

--checks to see if given object is on screen or not
--TODO
function on_screen(object)
    
end