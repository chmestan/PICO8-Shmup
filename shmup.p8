pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- init and startgame

function _init()

 mode = "start"
 blinkt=0
 transt = 0
 
end

function startgame()
 cls(0)
 
 ship=
  {x=20,y=64,
  sx=1,sy=2,
  spr=1}

	speedx=1
	speedy=2
 
 --anim
 flamespr=6
 muzzle=0

 lives = 5
 maxlives = 5

 t=0
 minutes = 0
 seconds = 0 
 
 starsinit()
 
 bullets={}
 
 enemies={}
 enemiesinit()
 
 explosions={}
 
 timershoot=0
 inv=0
 
 mode = "game"
 
end
-->8
-- updates

function _update()
 
 blinkt += 1
	if mode == "game" then
	 update_game()
	elseif mode == "start" then
	 update_start()
	elseif mode == "over" then
	 update_over()
	elseif mode == "trans" then
	 update_trans()
	end

end

function update_game()

 timershoot+=1

 input()
 shoot()

 animflame()
 muzzleupdt()
 animbullet()
 animenemies()
 animexpl()

 timepassing()
 starmoving()
 
 colcheck()
 
 if lives <= 0 then
  mode = "over"
  return
 end
 
end

function update_start()
 if btnp(5) then
  mode="trans"
 end
end

function update_over()
 if btnp(5) then
  mode ="trans"
 end
end

function update_trans()
 transt+=1
 if transt >= 60 then
  mode ="game"
  transt=0
  startgame()
 end
end

-->8
-- draw

function _draw()

 if mode == "game" then
	 draw_game()
	elseif mode == "start" then
	 draw_start()
	elseif mode == "over" then
	 draw_over()
 elseif mode =="trans" then
  draw_trans()
	end

end

function draw_game()
	cls(0)
	
	starfield()
	
	if inv <= 0 then
	 drawsprite(ship)
		spr(flamespr,ship.x-8,ship.y)
	else
	 if sin(t*4)<0.5 then
		 drawsprite(ship)
			spr(flamespr,ship.x-8,ship.y) 
  end	
	end
	
	for enm in all(enemies) do
		if enm.flash > 0 then 
		 enm.flash -=1
		 for i=1,15 do
		  pal(i,7)
		 end
		end
  drawsprite(enm)
  pal()
	end
	
	for blt in all(bullets) do
  drawsprite(blt)
	end

 muzzledraw()
 expldraw()
 
 uitimer()
 uilives()
 
end

function draw_start()
 cls(0)
 rect(16,16,112,112,8)
 for i=0,1 do
  for j=0,1 do
  circfill(16+96*i,16+96*j,4,0)
  circ(20+88*i,20+88*j,4,8)
  circfill(22+84*i,22+84*j,5,0)
  end
 end
 line(16,24,112,24,8)
 line(19,19,22,22,8)
 line(22,19,19,22,8)
 
 print("press x key to start",24,80,1)
end

function draw_over()
 cls(0)
 print("game over!",44,40,8)
 print("press x key to restart",20,80,blink())
end

function draw_trans()
 local screenclr=12
 if transt < 32 then
	 for i=0,8 do
	   for j=0,8 do
	    circfill(i*16,j*16,transt,screenclr)
	   end
	 end
	 print ("ready?", 64-12,64,0)
 elseif transt < 36 then
  cls(screenclr)
  print("go!",58,64,0)
 else
  for i=0,8 do
	   for j=0,8 do
	    circfill(i*16,j*16,transt-40,0)
	   end
	 end
 end
end
-->8
-- input 

function input()
 ship.sx=0
 ship.sy=0
 ship.spr=1
 
 -- movement x
 if btn(0) then
 	ship.sx=-speedx
 end
 if btn(1) then
 	ship.sx=speedx
 end 
 
 -- movement y
 if btn(2) then
  ship.sy=-speedy
  ship.spr=2
 end
 if btn(3) then
  ship.sy=speedy
  ship.spr=3
 end
 
 ship.x += ship.sx
 ship.y += ship.sy
 
 for blt in all(bullets) do
   blt.x += blt.spd
  if blt.x > 140 then
   del(bullets,blt)
  end
 end
 
  -- screen constraints
 if ship.x<8 then
 ship.x=8
 elseif ship.x>120 then
 ship.x=120
 end
 if ship.y<9 then
 ship.y=9
 elseif ship.y>111 then
 ship.y=111
 end
 
end

-->8
-- shoot and timer
-- shoot()
-- timepassing()

function shoot()
 local freq=15
 
 if btn(5) and timershoot>=freq then
  local newblt = 
   {x=ship.x+9,y=ship.y,spr=48,
   spd=3}
  add (bullets,newblt)
  timershoot=0
  
  muzzle=4
  --local soundnb = flr(rnd(2))
  --sfx(soundnb)
  sfx(0)
 end
end

--------------------------------

function timepassing()
 t+=1/30
 minutes = t/60
 seconds= t%60
end

--------------------------------

-->8
-- animations and ui
-- animflame()
-- muzzleupdt()
-- muzzledraw()
-- animbullet()

function animflame()
 -- animate flame
 flamespr += 0.25
 if flamespr >=8 then
  flamespr = 6
 end
end

--------------------------------

function muzzleupdt() -- update
 if muzzle>0 then
  muzzle -= 1
 end
end

--------------------------------

function muzzledraw() -- draw
 if muzzle > 0 then
  circfill(ship.x+11,ship.y+3,muzzle,7)
 end
end

--------------------------------

function animbullet()
 for blt in all(bullets) do
  blt.spr += 0.5
  if blt.spr >= 56 then
   blt.spr=48
  end
 end
end
 
--------------------------------

function uitimer()
 -- ui
 --rectfill(0,0,128,7,1)
 --rectfill(0,120,128,128,1)
 
 -- timer
 if minutes < 10 then 
    minlength = 1
 else minlength = 2
 end
 if minutes < 60 then
  print(flr(minutes)..":",116 - 4*minlength,1,7) 
  if seconds < 10 then
    print("0",120,1,7)
    print(flr(seconds),124,1,7)
  else print (flr(seconds),120,1,7)
  end
 end
end

--------------------------------

function uilives()
 sprheartfull = 32
 sprheartempty = 33
 y = 2
 for i=0,maxlives-1 do
  if lives > i then
  	spr(sprheartfull,2+i*8,y)
  else 
   spr(sprheartempty,2+i*8,y)
  end
 end
 spr(34,2+maxlives*8,y)
end

--------------------------------

function blink()
 local blinkframes={8,4,4,20,4,4}
 local blinkclr={}
 local clrs={0,1,13,7,13,1}
 for i=1,#blinkframes do
 	for j=1,blinkframes[i] do
 	 add (blinkclr,clrs[i])
 	end
 end

 if blinkt>#blinkclr then
  blinkt=1
 end
 return blinkclr[blinkt]
end

--------------------------------

function drawsprite(sp)
 spr(sp.spr,sp.x,sp.y)
end

--function drawarray(ar)
-- for i in all(ar) do
--  spr(i.spr,i.x,i.y)
-- end
--end

-->8
-- stars

function starsinit()
 nbofstars=110
 clrchoice = {1,2,5,6,13}
 stars={}
 for i=1,nbofstars do
  local newstar={}
  newstar.x=flr(rnd(128))
  newstar.y=flr(rnd(128))
  newstar.clr=flr(rnd(clrchoice))
  newstar.spd=flr(rnd(4)+1)
  add(stars,newstar)
 end
end

function starfield()
 for star in all(stars) do
   if star.spd >= 4 then
    line(star.x,star.y,star.x-1,star.y,star.clr)
   else
    pset(star.x,star.y,star.clr)
   end
 end
end

function starmoving()
 for star in all(stars) do
   star.x -= star.spd
   if star.x < 0 then
    star.x = 128
    star.y=flr(rnd(128))
    star.clr=flr(rnd(clrchoice))
    star.spd=flr(rnd(4)+1)
   end
 end
end
-->8
-- enemies

function enemiesinit()
 for i=1,3 do
  spawnenemy()
 end
end

function spawnenemy()
 local enm = {
  x=120,y=flr(rnd(128)-8),
  spr=35,spd=1,dir=1,
  hp=3,flash=0}
 add(enemies, enm)
end

function animenemies()
 for enm in all(enemies) do
	 enm.y+=enm.spd*enm.dir
--	 enm.x+=rnd(2)-1
	 
	 --move up and down
	 if enm.y >=120 then
	  enm.dir = -1
	 elseif enm.y <= 8 then
	  enm.dir = 1
	 end
  
  -- sprite
  enm.spr += 0.5
  if enm.spr >= 42 then
   enm.spr = 35
  end
 end
 
 if #enemies < 3 then 
  spawnenemy()
 end
 
end
-->8
--collisions

function col(a,b,al,ar,at,ab,bl,br,bt,bb)
 local a_l = a.x+al
 local a_r = a.x+ar
 local a_t = a.y+at
 local a_b = a.y+ab
  
 local b_l = b.x+bl
 local b_r = b.x+br	
 local b_t = b.y+bt
 local b_b = b.y+bb
 
 if a_t > b_b then return false end
 if a_b < b_t then return false end
 if a_l > b_r then return false end
 if a_r < b_l then return false end
 
 return true
 
end

function colcheck()

 local invtime = 60
 if inv <= 0 then
	 for enm in all(enemies) do
	  if col(enm,ship,1,6,0,7,0,7,0,7) then
	   lives-=1
	   sfx(2)
	   del(enemies,enm)
	   inv=invtime
	  end
	 end
	elseif inv > 0 then
	 inv -=1
 end

 for enm in all(enemies) do
  for bul in all(bullets) do
   if col(enm,bul,1,6,0,7,1,6,1,6) then
    enm.hp-=1
    enm.flash=3
    if enm.hp<=0 then
   	 explosion(enm.x,enm.y)
    	sfx(4)
    	del(enemies,enm)
    else
     sfx(5)
    end
    del(bullets,bul)
   end
  end
 end
 
end

function explosion(coordx,coordy)

 for i=1,(rnd(3)+6) do
 local clrchoice = {7,9,10,15}
 local expl = 
  {x=coordx+flr(rnd(13)-3),
  y=coordy+flr(rnd(13)-3),
  r=flr(rnd(4)+3),
  clr=clrchoice[flr(rnd(3)+1)] }
 add(explosions,expl)
  
 end
end

function animexpl()
 for expl in all(explosions) do
  expl.r-=1
  if expl.r<=0 then
   del(explosions,expl)
  end
 end
end

function expldraw()
	for expl in all(explosions) do
	 circfill(expl.x,expl.y,expl.r,expl.clr)
	end
end
__gfx__
000000002ee900002ee9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000128e9a00128e9a002ee90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000120000001288e97128e9a000000000000000000000009900000aa900000000000000000000000000000000000000000000000000000000000000000
0007700022888e9722888e990120000000000000000000000000a980000a99800000000000000000000000000000000000000000000000000000000000000000
0007700022888e990120000022888e9700000000000000000000a980000a99800000000000000000000000000000000000000000000000000000000000000000
0070070001200000128e9a0001288e990000000000000000000009900000aa900000000000000000000000000000000000000000000000000000000000000000
00000000128e9a002ee90000128e9a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000002ee90000000000002ee90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000898000008980000022290000222200002222000022220000922200002a22000022a200000000000000000000000000000000000000000000000000
00000111c009c00c0009c000092a22200292a220022a29200222a290022229200922229002922220000000000000000000000000000000000000000000000000
00111111cc0cc0cc000cc00002222990022222900922222009922220029a2220022aa2200222a920000000000000000000000000000000000000000000000000
92f77f2e1cccccc100cccc00029a2220022aa2200222a92002222990022222900922222009922220000000000000000000000000000000000000000000000000
8222222e01cccc100cccccc000011000000110000001100000011000000110000001100000011000000000000000000000000000000000000000000000000000
0011111100c00c00c1c00c1c000dd000000dd000000dd000000dd000000dd000000dd000000dd000000000000000000000000000000000000000000000000000
000001110090090010900901000ddd00000ddd00000dd00000ddd00000ddd000000dd000000dd000000000000000000000000000000000000000000000000000
0000000000000000000000000000dd000000dd00000dd00000dd000000dd0000000dd000000dd000000000000000000000000000000000000000000000000000
0ccccccc0ccccccc0000000000887800008887000078880000878e00008878000078870000878800000000000000000000000000000000000000000000000000
c7b77777c0000000c000000008878880088878800888878008888870088888800788888008788880000000000000000000000000000000000000000000111000
cbbbbbbbc0000000c000000008888870088888800788888008788880088788800888788008888780000000000000000000000000000000000000000001101100
0ccccccc0ccccccc0000000007887880087887800887887008887880078887800878887008878880000000000000000000000000000000000000000001111110
00000000000000000000000000044000000440000004400000044000000440000004400000044000000000000000000000000000000000000000000000551111
000000000000000000000000000ff000000ff000000ff000000ff000000ff000000ff000000ff000000000000000000000000000000000000000000000001111
000000000000000000000000000fff00000fff00000ff00000fff00000fff000000ff000000ff000000000000000000000000000000000000000000000000111
0000000000000000000000000000ff000000ff00000ff00000ff000000ff0000000ff000000ff000000000000000000000000000000000000000000000000111
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbb0b000bbb000000000000000000000000
001cc0000011cc00001ccc000001cc00000011000000010000c0000000cc00000000000000000000000000000b00a0bb00b0a0bb0013c7000000000000000000
01cc700001ccc7000001c7c000001cc000000c100c700c100c7000100cc7000008080808808008088080808000b0bbbb00a0bbbb000000000003b00000098000
010000000000000000000000000007c00c700cc00cc00c100cc001c00c1000100888088888800888888088800ba0bb000bb0bb08013ccb70003c7300009a7900
0000001000000000000000000c7000000cc007c001c00cc00c100cc0010001c0002000200200002002000200bb000ab0bb00ab00013ccbb000bccb00008aa800
0007cc10007ccc100c7c10000cc1000001c0000001c007c0010007c000007cc0007887200278872002788700ba000bb0ba00bb0000000000000b300000089000
000cc10000cc110000ccc10000cc1000001100000010000000000c000000cc000088880000888800008888003bbabb303bbab3000013c7000000000000000000
000000000000000000000000000000000000000000000000000000000000000000288200002882000028820003bbb30003bb3000000000000000000000000000
ddddddddd0d0d0d0d000d000d000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddd0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d000d000d00000000000000000000000000000000000000000000000000000000000000000000000000000000
ddddddddd0d0d0d000d000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddd0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d000d000d000d00000000000000000000000000000000000000000000000000000000000000000000000000
ddddddddd0d0d0d0d000d000d000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddd0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d000d000d00000000000000000000000000000000000000000000000000000000000000000000000000000000
ddddddddd0d0d0d000d000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddd0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d000d000d000d00000000000000000000000000000000000000000000000000000000000000000000000000
d0d0d0d0d010d0101010101010101010101010101000100010001000000000000000000000000000000000000000000000000000000000000000000000000000
0d0d0d0d0d0d0d0d0d0d0d0d010d010d010101010101010101010101010101010100010001000100000000000000000000000000000000000000000000000000
d0d0d0d010d010d01010101010101010101010100010001000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0d0d0d0d0d0d0d0d0d0d0d0d010d01010101010101010101010101010101010001000100000000000000000000000000000000000000000000000000000000
d0d0d0d0d010d0101010101010101010101010101000100010001000000000000000000000000000000000000000000000000000000000000000000000000000
0d0d0d0d0d0d0d0d0d0d0d0d010d010d010101010101010101010101010101010100010001000100000000000000000000000000000000000000000000000000
d0d0d0d010d010d01010101010101010101010100010001000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0d0d0d0d0d0d0d0d0d0d0d0d010d01010101010101010101010101010101010001000100000000000000000000000000000000000000000000000000000000
0000000000000000d0d0d0d00000000000d00d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000d0d0d0d0dddddddd0d00d00d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000d0d0d0d000000000d00d00d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000d0d0d0d0dddddddd00d00d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000d0d0d0d0000000000d00d00d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000d0d0d0d0ddddddddd00d00d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000d0d0d0d00000000000d00d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000d0d0d0d0dddddddd0d00d00d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000070000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000500000006000000070000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050505005606065077070770
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000500000006000000070000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000070000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111110000000000000000
00000000111888881000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111888881000000000000000
00000111888888888100000000000000000000000000000000000000000000000000000000000000000000000000000000000111888888888100000000000000
00011188888888888100000000000000000000000000000000000000000000000000000000000000000000000000000000011188888888888100000000000000
00000011888888888810000000000000000000000000000000000000000000000000000000000000000000000000000000000011888888888810000000000000
00000000118888888810000000000000000000000000000000000000000000000000000000000000000000000000000000000000118888888810000000000000
00000011888888888810000000000000000000000000000000000000000000000000000000000000000000000000000000000011888888888810000000000000
00001188888888888810000000000000000000000000000000000000000000000000000000000000000000000000000000001188888888888810000000000000
00000011888888888810000000000000000000000000000000000000000000000000000000000000000000000000000000000011888888888810000000000000
00000000111888888100000000000000000000000000000000000000000000000000000000000000000000000000000000000000111888888100000000000000
00000000018888888100000000011100000000000000000000000000000000000000000000000000000000000000000000000000018888888100000000011100
00000000188888888100000001188100000000000000000000000000000000000000000000000000000000000000000000000000188888888100000001188100
00000001888888881000011118888100000000000000000000000000000000000000000000000000000000000000000000000001888888881000011118888100
00000018888888881111188888888100000000000000000000000000000000000000000000000000000000000000000000000018888888881111188888888100
00000188888888881888888888881000000000000000000000000000000000000000000000000000000000000000000000000188888888881888888888881000
00001888888888888888888888881000000000000000000000000000000000000000000000000000000000000000000000001888888888888888888888881000
00001888888888888888888888880000000000000000000000000000000000000000000000000000000000000000000000001888888888888888888888880000
00018888888888888888888888810000000000000000000000000000000000000000000000000000000000000000000000018888888888888888888888810000
00018888888888888888888888100000000000000000000000000000000000000000000000000000000000000000000000018888888888888888888888100000
00018888888888888888888888100000000000000000000000000000000000000000000000000000000000000000000000018888888888888888888888100000
00018888888888888888888888100000000000000000000000000000000000000000000000000000000000000000000000018888888888888888888888100000
00018888888888888888888881000000000000000000000000000000000000000000000000000000000000000000000000018888888888888888888881000000
00001888888888888888888881000000000000000000000000000000000000000000000000000000000000000000000000001888888888888888888881000000
00001888888888888888888810000000000000000000000000000000000000000000000000000000000000000000000000001888888888888888888810000000
00000188888888888888888810000000000000000000000000000000000000000000000000000000000000000000000000000188888888888888888810000000
00000018888888888888111810000000000000000000000000000000000000000000000000000000000000000000000000000018888888888888111810000000
00000181111111111111000181000000000000000000000000000000000000000000000000000000000000000000000000000181111111111111000181000000
11001810000000000000000018100000000000000000000000000000000000000000000000000000000000000000000011001810000000000000000018100000
18118100000000000000000018100000000000000000000000000000000000000000000000000000000000000000000018118100000000000000000018100000
01881000000000000000000181000000000000000000000000000000000000000000000000000000000000000000000001881000000000000000000181000000
00110000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000110000000000000000000110000000
__sfx__
4801000037540325402e5402a54026540235401f5401d5401c5001850009000300003800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
48010000335502f5502a55026550235501f5501e5601c500185000900030000380000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
480300002e55038550175501d55029500105501f500015501c5000055009500305003850000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000f00001b0501f050230502505000000280502a0502c0502d0502f0502c0502c0002a0002d0002a0503305034050380503d050315003f0503f0503f0503f0502a00035000310002c00028000220002200000000
000400001e65019600206500765021650386002260022600236002460026600266003960034600356003660036600376003860032600006000060000600006000060000600006000060000600006000060000600
000100002572021700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
__music__
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344
00 43424344

