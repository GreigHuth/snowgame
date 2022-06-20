--non player objects, collectables and things like that

meteors={}

function draw_meteor(meteor)
    local t = meteor[4]
    spr(meteor[1], meteor[2], meteor[3])
end


function add_meteor(celx, cely)
    --sprn, x, y, timer for animation
    local meteor = {9,celx*8, cely*8, 0}
    add(meteors, meteor)
end


function draw_all_meteors()

    foreach(meteors, draw_meteor)
end
