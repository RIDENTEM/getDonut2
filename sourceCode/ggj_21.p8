pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
px=30
py=30
pl={}
l_radius=3
activate_light=false
light_active=false

local is_intro=true
local gg=false
local is_debugging=false
local invuln=false

local donuts_eaten=0
local eat_event=false

local all_donuts={}
local all_enemies={}

donut_spawns={
 {45,15,false},
 {20,85,false},
 {40,65,false},
 {60,55,false},
 {80,45,false},
 {100,35,false},
 {70,25,false},
 {90,100,false}

}
e_spawns={

 {0,60},
 {79,0},
 {125,80},
}


function create_player()
 n_player={}

 n_player.update=function(self)
  --input
  if(btn(2))then
   py-=1
  elseif btn(1) then
   px+=1
  elseif btn(3) then
   py+=1
  elseif btn(0) then
   px-=1
  end
  if(btn(4))then
   activate_light=true
  end
 end

 n_player.render=function(self)
  --player
  circfill(px,py,1,7)
 end

 return n_player
end

function create_enemy(x,y,s)
 n_emy={}
 n_emy.spr=s
 n_emy.x=x
 n_emy.y=y
 local aggro=rnd(1)+1
 
 n_emy.update=function(self)
  if(light_active)aggro=3
  if(light_active==false)aggro=rnd(1)+1
  if(self.x<px)self.x+=0.2*aggro
  if(self.x>px)self.x-=0.2*aggro
  if(self.y>py)self.y-=0.2*aggro
  if(self.y<py)self.y+=0.2*aggro

  if(px<=self.x+7 and 
     px>=self.x-3 and
     py<=self.y+7 and
     py>=self.y-1 and 
     invuln==false)then
   

   if(gg==false)end_game()
  end
 end

 n_emy.render=function(self)
  spr(self.spr,self.x,self.y)
 end
 
 add(all_enemies,n_emy)
end

function create_donut()
 n_donut={}
 n_donut.x=0
 n_donut.y=0
 n_donut.spr=1


 for x in all(donut_spawns)do
  if(x[3]==false)then     
   n_donut.x=x[1]
   n_donut.y=x[2]
   x[3]=true
   break
  end--end x check
 end--end donut spawns loop


 n_donut.update=function(self)
  --collision detection
  if(px<self.x+7 and px>self.x and
  py<self.y+7 and
  py>self.y)then
   for k,v in pairs(donut_spawns)do
    if(v[1]==self.x)v[3]=false
   end   
   donuts_eaten+=1
   sfx(0)
   --destroy donut
   del(all_donuts,self)
   
  end

 end--end update

 n_donut.render=function(self)
  if(self.x>=px-l_radius-4 and
     self.x<=px+l_radius and
     self.y<=py+l_radius and
     self.y>=py-l_radius-4 and
     light_active)then
   spr(self.spr,self.x,self.y)
  end
  --only render if they are colliding with light

 end--end render

 add(all_donuts,n_donut)
end--end donut maker

function begin()
 --create player

 pl=create_player()
 --create enemies
 create_enemy(e_spawns[1][1],e_spawns[1][2],3)
 create_enemy(e_spawns[2][1],e_spawns[2][2],4)
 create_enemy(e_spawns[3][1],e_spawns[3][2],5)
 --create donuts
 for i=0,4 do
  create_donut()
 end
 --get rid of intro overlay
end


function _update()

 if(is_intro==false)then
  --donuts
  for d in all(all_donuts)do
   d:update()
  end
  if(#all_donuts==0)then
   for i=0,5 do
    create_donut()
   end
  end

  for e in all(all_enemies)do
   e:update()
  end

  pl:update()
 end
 

 if(activate_light)l_radius+=1
 if(l_radius==10)activate_light=false
 if(l_radius>3)light_active=true
 if(l_radius<=3)light_active=false
 if(activate_light==false and l_radius>3)then
  l_radius-=1
 end
 if(is_intro and btnp(5))then
  begin()
  is_intro=false
 end
end


function end_game()
 gg=true
 sfx(1)
end

function reset_game()

 --reset score
 donuts_eaten=0
 --reset all tables
 for d in all(all_donuts)do
  del(all_donuts,d)
 end

 px=30
 py=30
 --reset enemy pos

  for i=1,3 do
   all_enemies[i].x=e_spawns[i][1]
   all_enemies[i].y=e_spawns[i][2]

  end

 --respawn all donuts
 for i=0,5 do
  create_donut()
 end
end

function _draw()
 cls()
 --level
 --top
 rectfill(0,0,127,6,1)
 --left
 rectfill(0,0,6,127,1)
 rectfill(0,127,127,121,1)
 rectfill(127,0,121,127,1)

 

 --light
 circfill(px,py,l_radius,10)
 

 if(is_intro==false)then
  --details
  print("eaten:"..donuts_eaten,7)
  print("press z to find donuts!",18,123,7)
  for d in all(all_donuts)do
   d:render()
  end
  for e in all(all_enemies)do
   e:render()
  end
  pl:render()
 end

 --debug
 if(is_debugging)then
  print(all_enemies[1].x,0,0,7)
  --print("total donuts:"..#all_donuts)
  for k,v in pairs(donut_spawns)do
   --print(v[3]) 
  end
 end--end debugging
 --cover screen with black overlay
 --have intro text and directions
 if(is_intro)then
  rectfill(6,6,121,121,0)
  print("get donut 2",39,60,7)
  print("press x to begin",30,70,7)
 
 end

 --game over screen can be black rect?
 if(gg)then
  rectfill(6,6,121,121,0)
  print("try again! press x!",30,60,7)
  if(btnp(5))then
   gg=false
   --reset game
   reset_game()
  end--if x pressed
 end
end--end draw


__gfx__
0000000000e7ee000077770000033300000bb00000b0b00000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000e7eee70077877700033330000999900000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700eee007ee078778700333333300999900088b880000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000ee0000e77777777733333333009990000888888000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000e700007e77887877000bb000009990000888888000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007007ee00eee77888877000bb000009900000888888000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000eeee7e007070707000bb000009900000088880000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000ee7e0007000700000bb000009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000400001d1501a150201500410002100011000110002100061000310004100051000610007100081000a10019100161000000000000000000000000000000000000000000000000000000000000000000000000
00100000110500f0500d0500a05006050020500205000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
