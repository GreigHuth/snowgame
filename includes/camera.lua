camera_pos = {
    x = 0, 
    y = 0
}


--returns camx, camy
function get_camera_pos()
    return peek2(0x5f28), peek2(0x5f2a)
end


function update_camera()

    local camera_speed = 1
    if player.x - camera_pos.x > 70 then 
        camera_pos.x += camera_speed
    elseif player.x - camera_pos.x < 54 then 
        camera_pos.x -= camera_speed
    end

    camera_speed = 1.4
    if player.y - camera_pos.y > 90 then 
        camera_pos.y += camera_speed
    elseif player.y - camera_pos.y < 40 then 
        camera_pos.y -= camera_speed
    end

    if camera_pos.x < 0 then camera_pos.x = 0 end
    if camera_pos.y < 0 then camera_pos.y = 0 end

    camera(camera_pos.x, camera_pos.y)
end

--checks to see if given object is on screen or not
--TODO
function on_screen(object)
    
end