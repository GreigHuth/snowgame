pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
--Made By Gurg
-- i want it to be made clear that i never said i was actually good at programming


--secret locations(given in cell coords)
-- 1,23

--GLOBAL TABLES
flag = {
    FOREGROUND = 0,
    SOLID = 1,
    SCANNABLE = 6
}

    
actors_d = {} --list of actors to be drawn

actors_u = {} --list of actors to only be updated

--priority includes
#include includes/math.lua
#include includes/player.lua
#include includes/camera.lua
#include includes/snow.lua

#include includes/scan.lua
#include includes/effects.lua

function _init()

    
    add(actors_d, player) -- player is always drawn so set that first #

    add(actors_u, player)
    add(actors_u, scan_rect)
    

    --globals
    game_over = false
    debug_on = true
    grid_x = 0
    grid_y = 0 --current grid position
    map_tile = 0
    flag_tile = 0
    hitboxes_on = false
    frame_counter = 0
    gravity = 0.1

    snow_setup()

    set_palette() 
    
end

function snow_setup()
    snow_init(10, -2)
    snow_init(30, -1)
    snow_init(42, -5)
    snow_init(55, 0)
    snow_init(90, -10)
    
    snow_init(10, -30)
    snow_init(30, -20)
    snow_init(42, -60)
    snow_init(55, -40)
    snow_init(90, -70)
end


function set_palette() 
    pal(2, 140, 1) --purple to true-blue
    pal(3, 131, 1) --green to blue-green
    pal(4, 129, 1)
    pal(14, 133, 1)
end


--checks to see if the box described is hitting something solid


-------------------------------------
-------------------------------------
--CORE FUNCTIONS
-------------------------------------
-------------------------------------

--prints debug information to screen
function debug()
    grid_x = flr(player.x/8)
    grid_y = flr(player.y/8)

    color(8)
    local c = get_camera_pos()

    dmesg = {} --need to reinitialise every frame

    local los = check_los()

    --add(dmesg, player.states.photo)
    --add(dmesg, abs(player.dy))
    --add(dmesg, player.x..","..player.y)
    --add(dmesg, player.s_target)
    --add(dmesg, "pos: "..grid_x..","..grid_y)
    --add(dmesg, "camerapos:"..c[0]..","..c[1])

    local line = 0
    for mesg in all(dmesg) do
        print (mesg, 5+c[0], line+c[1])
        line += 6
    end
end


--where you update the game logic can be 30 or 60
function _update60()
    frame_counter = (frame_counter+1)%stat(8)

    foreach(actors_u, function(obj) obj:update() end)
    
end 


function _draw()

    cls()

    map(0,0, 0,0, 150,150)

    update_camera() --checks to see if screen needs updating
    --draw_snow()--weather effects are drawn after everything else

    if hitboxes_on then 
        foreach(actors_d, function(obj) obj:draw_hitbox() end)
    end

    foreach(actors_d, function(obj) obj:draw() end)

    

    map(0,0, 0,0, 150,150, 1)
   
    if player.states.scanning == true then 
        scan_rect:draw()
    end

    if debug_on then
        debug()
    end
end 

 
__gfx__
00000000006666000066660000000000006666000000000000000000020002000200020000000000222222222222222200000000000000000000000000000000
00000000005a5a00005a5a0000666600005a5a000000000000000000020202000202020000000000222222222222222200000000000000000000000000000000
007007000055550000555500005a5a00005555000000000000000000011191000111910000000000022222222222222000000000000000000000000000000000
00077000006666000066660000555500006666000000000000000000009e9e00009e9e0000000000002222222222222000000000000000000000000000000000
00077000006666000066660000666600056666500006660000000000009999000099c90000000000002222222222220000000000000000000000000000000000
007007000050050005000050006666000098800000655a0000000000000990000009c00000000000000222222222220000000000000000000000000000000000
000000000000000000000000000000000aa9900050a5550000000000000990000009900000000000000022002222220000000000000000000000000000000000
00000000000000000000000000000000a000a0000566665000000000000990000009900000000000000002000222220000000000000000000000000000000000
00000000000000000066660000666600000666600066660000000000000000000000000000000000000002000222200000000000000000000000000000000000
0000000000000000005a5a0000555500006555500055556000000000000000000000000000000000000000000022200000000000000000000000000000000000
00a00a000000000000555500005a5a000005a5a000a5a50000000000000000000000000000000000000000000002200000000000000000000000000000000000
00000000006666000066660000666600000a66a000a66a0000000000000000000000000000000000000000000002000000000000000000000000000000000000
00000000005a5a000066665000666600006666600066666000000000000000000000000000000000000000000002000000000000000000000000000000000000
00a00a00006666000500000005000050006550050500556000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000006500000000056000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000650000000560000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600008006600000000000007bb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00656000506666000058850000700000006666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06656600556116600500005000666600008855000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
666666600617716000000000005bb500008855000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06000600061711600000000000655600006556000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08000800066116600000000000666600006666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000556666550000000005000050050000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000500550050566665050000005500000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000044400000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000558800000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000544500000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000045400000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000460400000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000005000050000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000005000050000000000000000000000000000000000000000000000000000000000000000000000000
111111110000000000c2220044111144122222225cc55cc50000000043344344044334344334440043434344443444444cc44c44000000000000000000000000
0100110100000000022c112044112144111111115c5555c50000000043434344004434344434440043343344433444444c4c4c44000000000000000000000000
00000100000000002c11c11212111111111111115cc55cc50333333043443344000433334434400043343334344004334c44c444000000000000000000000000
000000000000000021c21c12111212111111111155c55c55034444404443434400043343443340004434443434000033444c4444000000000000000000000000
0000000000000000211c12c211111111111111115cc55cc534433242443444340004434344334000444444444444444344c44444000000000000000000000000
0000000000000000c11c21cc12111111121111115c5555c5344333424443444400044443444444004444444434444043444c4444000000000000000000000000
00000000000000000211c12012211111122112115cc55cc53444444244433444000444434444440044434444340000434444c444000000000000000000000000
000000000000000000c22c00111111111111111155c55c55343222324443444400444443444444004443444434444443444c4444000000000000000000000000
00000000111111114132065011111111111111110000000303131330423332321111222111111111434343440000000077777777000000000000000000000000
00000000001111214132065001110110111111110000003403131330434344431111122111111111433444440000000070070007000000000000000000000000
00000000001211114132065001110010022111110000034403131330343333321111212111111111444444340000000070700007000000000000000000000000
00000000011112124132065001010000000111110000344203131330343442421112111111211111444444340000000077000077000000000000000000000000
00000000111111114132065001000010000211110003442203131330343442421121111111121111444444440000000070000707000000000000000000000000
00000000011211114132065001000010000001110034222203131330343333421111111111112121444444440000000070007007000000000000000000000000
00000000001221114132065001010010000000210342222203131330344444421111111111111221444444440000000070070007000000000000000000000000
00000000011111114132065011111111000000013422222203131330343222321111111111112221444344440000000077777777000000000000000000000000
000000001111111011111111111111111111111100000004000000000000000a1111111100000000eeeeeeee0000000000000000000000000000000000000000
00000000111121101111211111111111121111110000004400cccc000000000a1110001000000000eeeeeeee0000000000000000000000000000000000000000
00000000121111001211111101111111111211010000044100c7cc000000000a1000000000000000eeeeeeee0000000000000000000000000000000000000000
0000000011121210111112110111101111112101000044110c7cccc00000000a1000000000000000eeeeeeee0000000000000000000000000000000000000000
0000000011111111111111110111100112111100000441110cccccc0000000001000000000000000eeeeeeee0000000000000000000000000000000000000000
0000000012111110122111110011000111100100004411110cccccc00000000a1000000000000000eeeeeeee0000000000000000000000000000000000000000
0000000012211100122111110011000011000000044112210c2cc2c0000000001000000000000000eeeeeeee0000000000000000000000000000000000000000
00000000111111001111111100010000100000004411121104444440000000001110000000000000eeeeeeee0000000000000000000000000000000000000000
0000000000111111111c211100000000211111114000000077000077666666671111111100000000677777750000000000000000000000000000000000000000
000000000111211111c1c21100000000111211104400000067000065677677650110001100100010676676650000000000000000000000000000000000000000
00000000121111111c211c2100000000111111001440000067000065675775750000000100110011675775750000000000000000000000000000000000000000
000000001111121111c111c100000000111110001244000067000065667767750000000101110011677777750000000000000000000000000000000000000000
0000000011111111111c1c2100000000121100001114400067000065677677650000000101110111676676650000000000000000000000000000000000000000
000000001221111111c211c200000000111000001111440067000065675775750000000111111111675775750000000000000000000000000000000000000000
0000000012211111111c111c00000000110000001211144066666665667767750000001111111111676767650000000000000000000000000000000000000000
0000000011111111c1c2111100000000100000001112114475555555755555550001111111111111677777750000000000000000000000000000000000000000
0000000000000077a6a6770000000000000000000000000000000000000000000000000026262626262626000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000002774262600000000000000000000000000000000000000000000000000000000000000000000
000000000000007777a6770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000002774262600000000000000000000000000000000000000000000000000000000000000000000
0000000000000077a6a6770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000074262600000000000000000000000000000000000000000000000000000000000000000000
7777777777777777a6a6770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000074262600000000000000000000000000000000000000000000000000000000000000000000
77a6a6a6a6a6a6a6a6a6770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000074002600000000000000000000000000000000000000000000000000000000000000000000
7763a6a6a6a6a6a6a6a6770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000074002600000000000000000000000000000000000000000000000000000000000000000000
77777777777777777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000074002600000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000074002600000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000074000000000000000000000000000000000000000000000000000000000000000000000000
26262626262626262626262626262626262600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000074000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000026000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000074000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000074000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000074000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000074000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000074000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000074000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777770000000077777777000000007777777700000000777777770000000077777777000000007777777700000000777777770000000077777777
00000000000000000000000000000000000000000000000000000074000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000074000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000074000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000074000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000074000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000074000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000074000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000074000000000000000000000000000000000000000000000000000000000000000000000000
77777777000000007777777700000000777777770000000077777777000000007777777700000000777777770000000077777777000000007777777700000000
00000000000000000000000000000000000000000000000000007474000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0040c0c0c0400000000000000000000040c0c0c0c0c000000000000000000000004040000000000000000000000000000000000000000000000000000000000001404303034040400000400140000000400300010340414003030000400000004003030103074300010000000000000040034300030740000109000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000072727272537272727200000000000000000000000000000000000000000000000000000000
6100000000000000000000000000000000000000000000000000000000000066660000000d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000072537200000000000000000000000000000000000000000000000000000000000000
6100000000000000656262626262625864000000000000544444444444444444444444444444000000000000000000000000000000000000000c0d0e0f00000000000000000000000000000000000000000000000000000000000000000072537200000000000000000000000000000000000000000000000000000000000000
610000000000000062474a474a4747620000000000000000004847474747474c4c4a4a4a4762000000000000000000775c77000000000000001c1d1e1f00000000000000000000000000000000000000000000000000000000000000000072537200000000000000000000000000000000000000000000000000000000000000
610044000000000062474a474a4a47610000000000000000004847474747474c4c4747474762000000000000000000775c77000000000000002c2d2e2f00000000000000000000000000000000000000000000000000000000000000000072537200000000000000000000000000000000000000000000000000000000000000
610000000000000051474a4a474a4a620000000000000000004847474747474c4c4747474762000000000000000000775c77000000000000003c3d3e3f00000000000000000000000000000000000000000000000000000000000000000072537200000000000000000000000000000000000000000000000000000000000000
627400003a3b3c3d784a4a47474a476100000000000000000000484747474a4c4c4747474762000000000000000000775c77000000000000000000000000000000000000000000000000000046464646464646464600000000000000000072537200000000000000000000000000000000000000000000000000000000000000
61000000654444444444444444444a6200000000000000000000004847474c4c4c4c47474762000054627400000000775c77000000000000000000000000000000000000000000000000000057565756575657565700000000000000000072537200000000000000000000000000000000000000000000000000000000000000
61000065436363636340484a47474a68002200000000000000000048474c4c4c4c4c4c474762000000480000000000775c77000000000000000000000000000000000000000000000000000057565756575657565700000000000000000072537200000000000000000000000000000000000000000000000000000000000000
62444462740000000065444444444444444444750000004458000048474c546244444c4744440000004b0000000000775c77000000000000000000000000000000000000000000000000000057565756575657565700000000000000000072537200000000000000000000000000000000000000000000000000000000000000
62626274000000006543626262626262624362437500006262000048474c4c6262624c4762620000004b0000000000775c77000000000000000000000000000000000000000000000000000057565756455657565700000000000000000072537200000000000000000000000000000000000000000000000000000000000000
61404000000065434362626262626262626262624375005462000048474c4c6262624c475362000065437500007777775c77777700000000000000444444444444445874000000000000000057565756455657565700000000000000000072537200000000000000000000000000000000000000000000000000000000000000
62444444444444436262626262626262626262626243750047000048474c4c6262624c475362006262624375007700775c77007700000000000000626262626262626200000000000000544444444444444444444444444475000000000000537200000000000000000000000000000046464646464644444444444444444444
625362626262626262626262626262626262626262624444444444444444446262624c4c626200006262624344447272727272727242426262626262626262626262620000000000000000546262626262626262626262626262624c596272627200000000000000000000000000000046460000000000000000000000000000
625362626262626262626262626262626262626262626262626262626262626262534747626200006262626262727272727272727373736262626262626262626262740000000000000000000000000000000000000000000000004c626272627200000000000000000000000000004600000000000000000000000000000000
625362626262626262626262626262626262626262626262626262626262626262534747626262006262626262727272727200000072726262626262626262626274000000000000005444444444444444444444444444444444444c626272626262750000000000000000000000000000000000000000000000000000000000
625362626262626262626262626262626262626262626262626262626262626262624747536200000000000072727272727400007200000000000000000000000000000000000000000000000000000000000000000000000000724c726272626262620000000000000000000000000000000000000000000000000000000000
62537700546262626262626262626262626262626262626262626262626262626262475a536200000000000000000000000000720000000044444444444444797979797979797979797979797944444444444444444444440000724c726200000000000000000000000000000000000000000000000000000000000000000000
62537700006262626262626262626262626262626262626262625a5a5a5a5a5a5a5a5a5a626262626262620000007272727272000000000000000000000000000000000000000000000000000000000000000000000000000000724c726200000000000000000000000000000000000000000000000000000000000000000000
625300000000000000006662626262626262626262626262625a5a5a5a5a5a5a5a5a5a00626262626262626200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000724c726262626262620000000000000000000000000000000000000000000000000000000000
62537777777777777777777777777777626262626262625a5a5a5a626262626262620000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000724c726262626262626200000000000000000000000000000000000000000000000000000000
62536a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a7a5a5a5a5a62626262626262620000000000000000006262626262620000000000000000000000000000000000000000000000000000000000000000000000000000000000724c726262626262626262000000002100000000000000000000000000000000000000000000
62536a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a7a5a5a5a6262626262626262626262626262626262620000000000000000000000000000000000000000000000000044444444444444444444444444444444444400000000724c726262626262626262626262626262626262000000000000000000000000000000000000
62626a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a7a5a5a5a6262626262626262626262626200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000724c726262626262626262626262626262626200000000000000000000000000000000000000
00627777777777776a777777777777777777776262626262626262626262626262626262626262000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000724c726262626262626262626262626262626200000000000000000000000000000000000000
00620000000000776a6a7700000000000000000000000000000000000000000000000000006262626262000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000724c726200000000000000000000000000000000000000000000000000000000000000000000
0062000000000077776a7700000000000000000000000000000000000000000000000000006262626262620000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000724c726200000000000000000000000000000000000000000000000000000000000000000000
00620000000000776a6a7700000000000000000000000000000000000000000000000000006262626262620000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000724c726200000000000000000000000000000000000000000000000000000000000000000000
00000000000000776a7777000000000000000000000000000000000000000000000000000062626262626200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007247626200000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00040000000000000000000000000c0500e0501005011050130501505017050180500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
02 00424344
00 01424344

