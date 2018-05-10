pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- herbert
-- by fresnik

version = 2
local dirs = {stop={x=0,y=0,spr={0,1,2,3}},
              nw={x=-1,y=-1,spr={4,20,36,52}},
              ne={x=1,y=-1,spr={6,22,38,54}},
              se={x=1,y=1,spr={5,21,37,53}},
              sw={x=-1,y=1,spr={7,23,39,55}}}

game = {}
timers = {}

noisedx = rnd(1024)
noisedy = rnd(1024)
local lastmap = {}

function _init()
  menuitem(1, "instructions", show_instructions)
  menuitem(2, "toggle sound", toggle_sound)
  
  data = cartdata("fresnik_herbert_"..version)
  local highscore = 0
  local sound = 1
  if data then
    highscore=dget(0) or 0
    sound=dget(1) or 1
  end
  if sound == 0 then sound = false else sound = true end
  game.sound=sound
  game.highscore=highscore

  loading_init()
end

function _update()
  game.update_func()
end

function _draw()
  game.draw_func()
end

function loading_init()
  game.loading=false
  game.update_func = loading_update
  game.draw_func = loading_draw
end

function loading_update()
  if game.loading then title_init() end
end

function loading_draw()
  rectfill(42,62,86,70,1)
  print("loading...", 44, 64, 7)
  game.loading = true
end

-->8
-- instructions

function show_instructions()
  if game.update_func == title_update then game.prev_update_func = 'title'
  elseif game.update_func == game_update then game.prev_update_func = 'game' end
  game.instructions_page = 1
  game.instructions_max_page = 5
  game.update_func = instructions_update
  game.draw_func = instructions_draw
end

function instructions_update()
  if btnp(1) then game.instructions_page += 1 end
  if btnp(0) then game.instructions_page -= 1 end
  if game.instructions_page < 1 then game.instructions_page = 1 end
  if game.instructions_page > game.instructions_max_page then game.instructions_page = game.instructions_max_page end
  if btnp(5) then
    if game.prev_update_func == 'title' then
      game.update_func = title_update
      game.draw_func = title_draw
    elseif game.prev_update_func == 'game' then
      game.update_func = game_update
      game.draw_func = game_draw
    end
  end
end

function instructions_draw()
  rectfill(0,120,128,128,0)
  hcenter('version '..version, 121, 5)
  rectfill(14,16,114,112,1)
  rectfill(15,17,113,111,10)
  rectfill(16,18,112,110,1)
  rectfill(105,14,111,22,1)
  rect(105,14,111,22,10)
  print('x',107,16,10)
  if game.instructions_page == 1 then
    hcenter('story', 20, 10)
    hcenter('the water is rising', 40, 7)
    hcenter('due to global warming.', 50, 7)
    hcenter('everything we do', 65, 7)
    hcenter('contributes to our doom.', 75, 7)
    hcenter('use arrows to turn page', 92, 10)
    hcenter('press x to close', 100, 10)
  elseif game.instructions_page == 2 then
    hcenter('starting screen', 20, 10)
    hcenter('select a world', 30, 7)
    hcenter(smallcaps('(to die in)'), 38, 7)
    hcenter('use up/down to', 50, 7)
    hcenter('zoom in and out', 60, 7)
    hcenter('use left/right to', 70, 7)
    hcenter('change starting area', 80, 7)
    hcenter('press x to start', 90, 7)
    hcenter('the game', 100, 7)
  elseif game.instructions_page == 3 then
    hcenter('game controls', 20, 10)
    hcenter('use arrow keys to run.', 30, 7)
    hcenter('once you start', 40, 7)
    hcenter('you cannot stop.', 50, 7)
    hcenter('must move diagonally.', 60, 7)
    hcenter('need to press two keys.', 70, 7)
    hcenter(smallcaps('up and left'), 80, 7)
    hcenter(smallcaps('up and right'), 86, 7)
    hcenter(smallcaps('down and left'), 92, 7)
    hcenter(smallcaps('down and right'), 98, 7)
  elseif game.instructions_page == 4 then
    hcenter('powerups', 20, 10)
    spr(12,20,35)
    print('speed boost (4x)', 34, 35, 7)
    spr(13,20,50)
    print('speed bump (1x)', 34, 50, 7)
    spr(14,20,65)
    print('water resistance', 34, 65, 7)
    spr(15,20,80)
    print('water reduction', 34, 80, 7)
  elseif game.instructions_page == 5 then
    hcenter('tips', 20, 10)
    hcenter('running leaves a', 30, 7)
    hcenter('trail of water.', 40, 7)
    hcenter('touching water', 50, 7)
    hcenter('drains your life.', 60, 7)
    hcenter('life regenerates.', 70, 7)
    hcenter('run speed ramps up.', 80, 7)
    hcenter('water level rises', 90, 7)
    hcenter('over time.', 100, 7)
  end
  if game.instructions_page != game.instructions_max_page then
    rectfill(103,101,114,112,1)
    rect(103,101,114,112,10)
    spr(9, 105, 103)
  end
  if game.instructions_page != 1 then
    rectfill(14,101,25,112,1)
    rect(14,101,25,112,10)
    spr(8, 16, 103)
  end
end

-->8
-- title

function title_init()
  game.tile={x=-23,y=-23}
  game.lasttile={x=-23,y=-23}
  game.cam={x=0,y=0}
  game.dir=dirs.stop
  game.tilesize=2.01
  game.starting=false
  game.currenthint=1
  game.hintpos=8
  game.hintpause=nil
  game.hints={
    -- press p for menu
    {
      { text='press p for menu/instructions', pos=5 }
    },
    -- use up/down to zoom in/out
    {
      { text='use', pos=16, },
      { sprite=10, pos=32 },
      { sprite=11, pos=44 },
      { text='to zoom in/out', pos=56 }
    },
    -- use left/right to change starting point
    {
      { text='use', pos=14, },
      { sprite=8, pos=30 },
      { sprite=9, pos=42 },
      { text='to select world', pos=54 }
    },
    -- press x to start
    {
      { text='press x to start', pos=32 }
    }
  }

  -- terrainmap_colors = {1,  1,  1,  1,  1,  1,  1, -- deep ocean
  --                    13, 12, 15,    -- coastline
  --                    11, 11, 3, 3, 3, -- green land
  --                    4,  5,  6,  7} -- mountains
  game.terrainmap_sprites = {
                      16,  16,  16,  16, -- mountains
                      17, 17, 17, 17, 17, -- green land
                      18, 18, 18,    -- coastline
                      19} -- deep ocean

  --terrainmap_sprites = {16,16,16,16,16,17,17,17,17,18,18,18,19}
  recalc_title_map()

  game.update_func = title_update
  game.draw_func = title_draw
end

function recalc_title_map()
  for x=0,63 do
    for y=0,63 do
      calc_tile_sprite(x, y)
    end
  end
end

function title_update()
  if game.starting then
    game.tilesize *= 1.05
    if game.tilesize > 8 then game_init() end
  else
    if btn(2) then game.tilesize *= 1.05
    elseif btn(3) then game.tilesize *= 0.95 end
    if btnp(1) then
      noisedx += 1
      loading_init()
      --recalc_title_map()
    elseif btnp(0) then
      noisedx -= 1
      loading_init()
      --recalc_title_map()
    end
    if game.tilesize > 8 then game.tilesize = 8
    elseif game.tilesize < 2.01 then game.tilesize = 2.01 end
    if btnp(5) then game.starting=true end
  end

  update_tiles()
  check_for_new_tiles()
end

function title_draw()
  cls()
  title_draw_map()
  rectfill(0,0,128,4,0)
  rectfill(0,0,4,120,0)
  rectfill(120,0,128,128,0)
  rectfill(0,120,128,128,0)
  --spr(64,37,10,7,2)
  sspr(0,32,53,13,0,min(0,time()*25-30),127,30)
  title_draw_hint()
end

function title_draw_map()
  for x=0,63 do
    for y=0,63 do
      val = mget(x,y)
      sx = (val-16)*8
      sspr(sx,8,8,8,
        x*game.tilesize-(game.tilesize*32-64),
        y*game.tilesize-(game.tilesize*32-64),
        ceil(game.tilesize),ceil(game.tilesize))
    end
  end
  sspr(8,0,8,8,
    31*game.tilesize-(game.tilesize*32-64),
    31*game.tilesize-(game.tilesize*32-64),
    ceil(game.tilesize),ceil(game.tilesize))
end

function title_draw_hint()
  local hint=game.hints[game.currenthint]
  for i=1,#hint do
    if hint[i].text != nil then
      print(hint[i].text, hint[i].pos, 122 + game.hintpos, 10)
    elseif hint[i].sprite != nil then
      spr(hint[i].sprite, hint[i].pos, 120 + game.hintpos)
    end
  end

  if game.hintpos > 0 then game.hintpos -= 1
  elseif game.hintpause == nil then game.hintpause = time()
  elseif time() - game.hintpause > 3 then
    game.currenthint %= #game.hints
    game.currenthint += 1
    game.hintpos = 8
    game.hintpause = nil
  end
end

-->8
-- game

function game_init()
  game.dir=dirs.stop
  game.cam={x=8,y=8}
  game.speed={
    current=0,
    acc=1.03,
    currentmax=2, -- top speed, changes over time to increase difficulty
    max=4,        -- maximum top speed
    water=1       -- speed over water
  }
  game.life=100
  game.lastlife=100
  game.maxlife=200
  game.score=0
  game.lastscore=0
  game.maxscore=9999
  game.tile={x=0,y=0}
  game.lasttile={x=0,y=0}
  game.lasttiles={}
  game.low_life_color=2
  game.check_water_collision=true
  game.powerup_locs={}
  game.active_powerups={}
  game.next_powerup_spawn=9999
  game.powerup_min_spawn_time=5
  game.powerup_spawn_time=5
  game.powerup_max_count=4
  game.powerup_fading_color=8
  game.herbert_anim_idx=0
  game.herbert_anim_speed=0.5

  generate_random_powerup()

  timers = {
    low_life = 0,
    fading_powerup = 0,
    herbert_anim = 0
  }

  -- terrainmap_sprites = {16,16,16,16,16,17,17,17,17,18,18,18,19}
  -- terrainmap_sprites = {19, -- deep ocean
  --                    18, 18, 18,    -- coastline
  --                    17, 17, 17, 17, 17, -- green land
  --                    16,  16,  16,  16} -- mountains

  for x=0,16 do
    for y=0,16 do
      calc_tile_sprite(x, y)
    end
  end

  game.update_func = game_update
  game.draw_func = game_draw
end

function game_update()
  if btn(0) and btn(2) then game.dir=dirs.nw
  elseif btn(1) and btn(3) then game.dir=dirs.se
  elseif btn(1) and btn(2) then game.dir=dirs.ne
  elseif btn(0) and btn(3) then game.dir=dirs.sw end

  if game.dir != dirs.stop then
    if game.speed.current==0 then
      game.next_powerup_spawn=time()+rnd(game.powerup_spawn_time)+game.powerup_min_spawn_time
      game.speed.current=0.3
    else
      game.speed.current=min(game.speed.currentmax,game.speed.current*game.speed.acc)
    end
    game.herbert_anim_speed = 0.2/game.speed.current
  end

  update_tiles()
  check_for_new_tiles()

  if game.check_water_collision and is_touching_water() then
    game.speed.current = game.speed.water
    game.life -= 1
    if game.life == -1 then gameover_init() end
  end

  -- activate powerups we are in contact with
  local powerup_idx = powerup_being_touched()
  if powerup_idx != nil then
    local powerup = game.powerup_locs[powerup_idx].type
    add(game.active_powerups,{start_time=time(),powerup=powerup})
    if powerup.activation_func then powerup.activation_func() end
    del(game.powerup_locs,game.powerup_locs[powerup_idx])
  end

  -- deactivate powerups that are expired
  for i=#game.active_powerups,1,-1 do
    local powerup = game.active_powerups[i]
    if time() - powerup.start_time > (powerup.powerup.duration or 0) then
      if powerup.powerup.deactivation_func then powerup.powerup.deactivation_func() end
      del(game.active_powerups, game.active_powerups[i])
    end
  end

  if time() > game.next_powerup_spawn then
    game.next_powerup_spawn=time()+rnd(game.powerup_spawn_time)+game.powerup_min_spawn_time
    generate_random_powerup()
  end

  game.lasttile.x = game.tile.x
  game.lasttile.y = game.tile.y

  -- update score, life, maxspeed and terrain
  game.score += flr(game.speed.current*game.speed.current/8.0)
  if game.score > game.maxscore then game.score = game.maxscore end

  if game.score != game.lastscore then
    if flr(game.score / 10) != flr(game.lastscore / 10) then
      game.life += flr(game.score/10) - flr(game.lastscore/10)
      if game.life > game.maxlife then game.life = game.maxlife end
    end
    if flr(game.score / 250) != flr(game.lastscore / 250) then
      add(game.terrainmap_sprites, 19)
    end
    if flr(game.score / 10) != flr(game.lastscore / 10) then
      game.speed.currentmax += 0.05
      if game.speed.currentmax > game.speed.max then game.speed.currentmax = game.speed.max end
    end
  end

  dbg_cls()
  dbg_add('fps:'..stat(7), 2, 2, 10)
  dbg_add('mem:'..stat(0), 2, 10, 10)
end

function update_tiles()
  if game.dir.x > 0 then
    if game.cam.x > game.speed.current then
      game.cam.x -= game.speed.current
    else
      game.cam.x = game.cam.x - game.speed.current + 8
      game.tile.x += 1
    end
  elseif game.dir.x < 0 then
    if game.cam.x < 16 then
      game.cam.x += game.speed.current
    else
      game.cam.x = game.cam.x + game.speed.current - 8
      game.tile.x -= 1
    end
  end
  if game.dir.y > 0 then
    if game.cam.y > game.speed.current then
      game.cam.y -= game.speed.current
    else
      game.cam.y = game.cam.y - game.speed.current + 8
      game.tile.y += 1
    end
  elseif game.dir.y < 0 then
    if game.cam.y < 16 then
      game.cam.y += game.speed.current
    else
      game.cam.y = game.cam.y + game.speed.current - 8
      game.tile.y -= 1
    end
  end
end

function check_for_new_tiles()
  -- check if we moved a tile. if so, shift map and calculate new border tiles
  if (game.tile.x != game.lasttile.x or game.tile.y ~= game.lasttile.y) then
    for x=0,16 do
      for y=0,16 do
        lastmap[y*17+x] = mget(x,y)
      end
    end

    local dx = game.tile.x - game.lasttile.x
    local dy = game.tile.y - game.lasttile.y
    for x=1,15 do
      for y=1,15 do
        mset(x, y, lastmap[(x+dx)+(y+dy)*17])
      end
    end
    local cnt = 0
    for x=0,16,16 do
      for y=0,16 do
        calc_tile_sprite(x, y)
      end
    end
    for y=0,16,16 do
      for x=1,15 do
        calc_tile_sprite(x, y)
      end
    end

    -- add tile we moved from to the lasttiles trail
    if (#game.lasttiles > 499) then
      del(game.lasttiles, game.lasttiles[1])
    end
    local lasttile = {x=game.lasttile.x,y=game.lasttile.y}
    add(game.lasttiles, lasttile)

    game.score += 1
  end
end

function game_draw()
  cls()
  draw_map()
  draw_lasttiles()
  draw_powerups()
  draw_herbert()
  draw_hud()
  dbg_show()
  update_after_draw()
end

function update_after_draw()
  game.lastscore = game.score
  game.lastlife = game.life
end

function draw_map()
  map(0, 0, game.cam.x - 16, game.cam.y - 16, 17, 17)
end

function draw_lasttiles()
  for i=1,#game.lasttiles do
    local tile = game.lasttiles[i]
    local x = tile.x - game.tile.x
    local y = tile.y - game.tile.y
    spr(18, 48+x*8+game.cam.x,48+y*8+game.cam.y)
  end
end

function draw_powerups()
  -- draw powerup icons on map
  for i=1,#game.powerup_locs do
    local sprite = 12
    if game.powerup_locs[i].type == powerup_types.speed_boost then sprite=12
    elseif game.powerup_locs[i].type == powerup_types.speed_bump then sprite=13
    elseif game.powerup_locs[i].type == powerup_types.water_invulnerability then sprite=14
    elseif game.powerup_locs[i].type == powerup_types.water_reduction then sprite=15 end

    local x = game.powerup_locs[i].x - game.tile.x
    local y = game.powerup_locs[i].y - game.tile.y
    local dist = sqrt(x/10*x/10+y/10*y/10) -- multiplication may not reach 32k (pico-8 limit)
    if dist > 0.7 then
      local a = atan2(x, y)
      local icon_radius = 4
      if game.powerup_locs[i].d < 62 then game.powerup_locs[i].d *= 1.2
      elseif game.powerup_locs[i].i <= 0 then icon_radius = 3
      else game.powerup_locs[i].i -= 1
      end
      x = max(-54+icon_radius,min(58-icon_radius,game.powerup_locs[i].d*cos(a)))
      y = max(-54+icon_radius,min(58-icon_radius,game.powerup_locs[i].d*sin(a)))


      if #game.powerup_locs == game.powerup_max_count and i == 1 then
        if time() - timers.fading_powerup > 0.5 then
          if game.powerup_fading_color == 8 then game.powerup_fading_color = 15 else game.powerup_fading_color = 8 end
          timers.fading_powerup = time()
        end
        circfill(60+x,60+y,1+icon_radius,game.powerup_fading_color)
      else
        circfill(60+x,60+y,1+icon_radius,15)
      end
      sspr(sprite*8,0,8,8,60-icon_radius+x,60-icon_radius+y,icon_radius*2,icon_radius*2)
    else spr(sprite,48+x*8+game.cam.x,48+y*8+game.cam.y) end
  end
  -- draw active powerup timers
  local y = 112
  local x = 100
  for i=1,#game.active_powerups do
    local powerup = game.active_powerups[i]
    local time_left = (powerup.powerup.duration or 0) - time() + powerup.start_time
    rectfill(x,y,x+20,y+10,0)
    if powerup.powerup == powerup_types.speed_boost then
      spr(12, x, y+1)
    elseif powerup.powerup == powerup_types.speed_bump then
      spr(13, x, y+1)
    elseif powerup.powerup == powerup_types.water_invulnerability then
      spr(14, x, y+1)
    end
    print(float2str(time_left,1), x + 9, y + 2, 10)
    y -= 10
  end
end

function draw_herbert()
  spr(game.dir.spr[game.herbert_anim_idx+1], 56, 56)
  if time() - timers.herbert_anim > game.herbert_anim_speed then
    timers.herbert_anim = time()
    game.herbert_anim_idx += 1
    game.herbert_anim_idx %= #game.dir.spr
  end
  if (game.speed_boost_count or 0) > 0 then
    local rx = game.dir.x
    local ry = game.dir.y
    line(60-rx*4, 60-ry*4, 60-rx*16, 60-ry*16, 8)
    line(60-rx*4, 60-ry*4, 60-rx*10, 60-ry*12, 9)
    line(60-rx*4, 60-ry*4, 60-rx*12, 60-ry*10, 9)
    line(60-rx*4, 60-ry*4, 60-rx*6, 60-ry*8, 10)
    line(60-rx*4, 60-ry*4, 60-rx*8, 60-ry*6, 10)
  end
end

function draw_hud()
  rectfill(0,0,128,4,0)
  rectfill(0,0,4,120,0)
  rectfill(120,0,128,128,0)
  rectfill(0,120,128,128,0)

  print(smallcaps('score: '..tostr(game.score)), 4, 122, 10)

  local life_color=11
  if (game.life < game.lastlife) then life_color=8
  elseif game.life > game.lastlife then life_color=3
  else
    if game.life < 25 then
      if time() - timers.low_life > 0.5 then
        if game.low_life_color == 2 then game.low_life_color = 8 else game.low_life_color = 2 end
        timers.low_life = time()
      end
      life_color = game.low_life_color
    elseif game.life < 50 then life_color=9
    elseif game.life < 90 then life_color=10 end
  end
  print(smallcaps('life:'), 54, 122, 10)
  print(tostr(game.life), 74, 122, life_color)

  local water_level=0
  for i=1,#game.terrainmap_sprites do if game.terrainmap_sprites[i] == 19 then water_level += 1 end end
  print(smallcaps('water: '..tostr(water_level)), 90, 122, 10)
end

function calc_tile_sprite(x,y)
  -- starting area is a special case
  if (abs(game.tile.x+x-8) < 7 and abs(game.tile.y+y-8) < 7) then
    mset(x, y, 17)
    return
  end
  local octaves = 5
  local freq = .007
  local max_amp = 0
  local amp = 1
  local value = 0
  local persistance = .65
  for n=1,octaves do

    value = value + simplex2d(noisedx + freq * (game.tile.x + x),
                              noisedy + freq * (game.tile.y + y))
    max_amp += amp
    amp *= persistance
    freq *= 2
  end
  value /= max_amp
  if value>1 then value = 1
  elseif value<-1 then value = -1 end
  value += 1
  value *= #game.terrainmap_sprites/2
  value = flr(value+.5)
  if value < 1 then value = 1 end
  mset(x, y, game.terrainmap_sprites[value])
end

function is_touching_water()
  local left = 8
  local top = 8
  if game.cam.x > 8 then left = 7 end
  if game.cam.y > 8 then top = 7 end

  return mget(left,top) > 17 or
    mget(left+1,top) > 17 or
    mget(left,top+1) > 17 or
    mget(left+1,top+1) > 17 or
    tbl_intersect(game.lasttiles,left,top,2) != nil or
    tbl_intersect(game.lasttiles,left+1,top,2) != nil or
    tbl_intersect(game.lasttiles,left,top+1,2) != nil or
    tbl_intersect(game.lasttiles,left+1,top+1,2) != nil
end

function tbl_intersect(tbl,x,y,skip)
  for i=1,#tbl-(skip or 0) do
    local dx = tbl[i].x - game.tile.x + 8
    local dy = tbl[i].y - game.tile.y + 8
    if dx == x and dy == y then return i end
  end
  return nil
end

function powerup_being_touched()
  local left = 8
  local top = 8
  if game.cam.x > 8 then left = 7 end
  if game.cam.y > 8 then top = 7 end

  local powerup = tbl_intersect(game.powerup_locs,left,top) or
                  tbl_intersect(game.powerup_locs,left+1,top) or
                  tbl_intersect(game.powerup_locs,left,top+1) or
                  tbl_intersect(game.powerup_locs,left+1,top+1)
  return powerup
end

-->8
-- game over

function gameover_init()
  game.tile.x-=23
  game.tile.y-=23
  for x=0,63 do
    for y=0,63 do
      calc_tile_sprite(x, y)
    end
  end
  game.cam={x=0,y=0}
  game.ending = true
  if game.score > game.highscore then
    dset(0,game.highscore)
    game.highscore = game.score
  end
  game.update_func = gameover_update
  game.draw_func = gameover_draw
end

function gameover_update()
  if game.ending then
    game.tilesize *= 0.95
    if game.tilesize < 2 then
     game.tilesize = 2.01
      game.ending = false
    end
  end
  if btnp(5) then
    noisedx = rnd(1024)
    noisedy = rnd(1024)
    loading_init()
  end
end

function gameover_draw()
  cls()
  title_draw_map()
  rectfill(0,0,128,4,0)
  rectfill(0,0,4,120,0)
  rectfill(120,0,128,128,0)
  rectfill(0,120,128,128,0)
  if not game.ending then
    rectfill(25,17,103,27,0)
    hcenter('g a m e   o v e r', 20, 8)
    rectfill(27,69,101,97,1)
    rect(28,70,100,96,10)
    local water_level=0
    for i=1,#game.terrainmap_sprites do if game.terrainmap_sprites[i] == 19 then water_level += 1 end end
    print('water level: '..water_level, 31, 73, 10)
    print('      score: ', 31, 81, 10)
    print(tostr(game.score), 83, 81, 11)
    print(' high score: ', 31, 89, 10)
    local highscore_color = 10
    if game.score == game.highscore then highscore_color = 11 end
    print(tostr(game.highscore), 83, 89, highscore_color)
    rectfill(25,107,103,117,1)
    hcenter('press x to retry', 110, 10)
  end
end

-->8
-- powerups

function generate_random_powerup()
  local keyset = {}
  for k in pairs(powerup_types) do
    add(keyset, k)
  end
  local powerup_type = powerup_types[keyset[ceil(rnd(#keyset))]]
  local x = (flr(rnd(50))-25)*2 + game.tile.x
  local y = (flr(rnd(50))-25)*2 + game.tile.y

  if #game.powerup_locs == game.powerup_max_count then
    del(game.powerup_locs,game.powerup_locs[1])
  end
  -- d is the starting distance from herbert that the powerup icons spawns, moving away to the edge
  -- i is the time the powerup icons should stay full size on the edge before minimizing
  add(game.powerup_locs, {x=x,y=y,type=powerup_type,d=10,i=30})
end

function powerup_water_invulnerability_start()
  game.check_water_collision = false
end

function powerup_water_invulnerability_stop()
  game.check_water_collision = true
end

function store_current_speeds()
  if game.speed.oldcurrent == nil then game.speed.oldcurrent = game.speed.current end
  if game.speed.oldcurrentmax == nil then game.speed.oldcurrentmax = game.speed.currentmax end
  if game.speed.oldwater == nil then game.speed.oldwater = game.speed.water end
end

function restore_current_speeds()
  game.speed.current = game.speed.oldcurrent
  game.speed.currentmax = game.speed.oldcurrentmax
  game.speed.water = game.speed.oldwater
  game.speed.oldcurrent = nil
  game.speed.oldcurrentmax = nil
  game.speed.oldwater = nil
end

function powerup_speed_bump_start()
  printh('activating speed bump, currentspeed is '..tostr(game.speed.current)..', currentmaxspeed is '..tostr(game.speed.currentmax)..' and waterspeed is '..tostr(game.speed.water))
  store_current_speeds()
  game.speed.current = 0
  game.speed.currentmax = 1
  game.speed.water = 1
  game.speed_bump_count = (game.speed_bump_count or 0) + 1
  local speed_bumps_left = game.speed_bump_count
  local powerup_start_time = 0
  -- remove any active speed boost powerups and older speed bump timers
  game.speed_boost_count = 0
  for i=#game.active_powerups,1,-1 do
    if game.active_powerups[i].powerup == powerup_types.speed_boost then
      del(game.active_powerups,game.active_powerups[i])
    elseif game.active_powerups[i].powerup == powerup_types.speed_bump then
      if speed_bumps_left == game.speed_bump_count then
        powerup_start_time = game.active_powerups[i].start_time
      end
      game.active_powerups[i].start_time = powerup_start_time
      if speed_bumps_left > 1 then
        del(game.active_powerups,game.active_powerups[i])
        speed_bumps_left -= 1
      end
    end
  end
  game.speed_bump_count = 1
end

function powerup_speed_bump_stop()
  game.speed_bump_count -= 1
  -- don't slow down until the last speed boost powerup has expired
  if game.speed_bump_count == 0 then
    printh('deactivating speed bump, setting currentspeed to '..tostr(game.speed.oldcurrent)..', currentmaxspeed to '..tostr(game.speed.oldcurrentmax)..' and waterspeed to '..tostr(game.speed.oldwater))
    restore_current_speeds()
  end
end

function powerup_speed_boost_start()
  printh('activating speed boost, currentspeed is '..tostr(game.speed.current)..', currentmaxspeed is '..tostr(game.speed.currentmax)..' and waterspeed is '..tostr(game.speed.water))
  store_current_speeds()
  game.speed.current = game.speed.max
  game.speed.currentmax = game.speed.max
  game.speed.water = game.speed.max
  game.speed_boost_count = (game.speed_boost_count or 0) + 1
  local speed_boosts_left = game.speed_boost_count
  local powerup_start_time = 0
  -- remove any active speed bump powerups and older speed boost timers
  game.speed_bump_count = 0
  for i=#game.active_powerups,1,-1 do
    if game.active_powerups[i].powerup.type == powerup_types.speed_bump then
      del(game.active_powerups,game.active_powerups[i])
    elseif game.active_powerups[i].powerup == powerup_types.speed_boost then
      if speed_boosts_left == game.speed_boost_count then
        powerup_start_time = game.active_powerups[i].start_time
      end
      game.active_powerups[i].start_time = powerup_start_time
      if speed_boosts_left > 1 then
        del(game.active_powerups,game.active_powerups[i])
        speed_boosts_left -= 1
      end
    end
  end
  game.speed_boost_count = 1
end

function powerup_speed_boost_stop()
  game.speed_boost_count -= 1
  -- don't slow down until the last speed boost powerup has expired
  if game.speed_boost_count == 0 then
    printh('deactivating speed boost, setting currentspeed to '..tostr(game.speed.oldcurrent)..', currentmaxspeed to '..tostr(game.speed.oldcurrentmax)..' and waterspeed to '..tostr(game.speed.oldwater))
    restore_current_speeds()
  end
end

function powerup_water_reduction()
  del(game.terrainmap_sprites, 19)
end

powerup_types = {
  water_invulnerability = {
    duration=10.0,
    activation_func=powerup_water_invulnerability_start,
    deactivation_func=powerup_water_invulnerability_stop
  },
  speed_bump = {
    duration=10.0,
    activation_func=powerup_speed_bump_start,
    deactivation_func=powerup_speed_bump_stop
  },
  speed_boost = {
    duration=5.0,
    activation_func=powerup_speed_boost_start,
    deactivation_func=powerup_speed_boost_stop
  },
  water_reduction = {
    activation_func=powerup_water_reduction
  }
}

-->8
-- utils

function toggle_sound()
  game.sound = not game.sound
  if game.sound then newsfx=1 else newsfx=0 end
  dset(1, newsfx)
end

function hcenter(s,y,c)
  print(s,64-#s*2,y,c)
end

function float2str(f,d)
  return flr(f)..'.'..flr(f%1 * 10^d)
end

function smallcaps(s)
  local d=""
  local c
  for i=1,#s do
    local a=sub(s,i,i)
    if a!="^" then
      if not c then
        for j=1,26 do
          if a==sub("abcdefghijklmnopqrstuvwxyz",j,j) then
            a=sub("\65\66\67\68\69\70\71\72\73\74\75\76\77\78\79\80\81\82\83\84\85\86\87\88\89\90\91\92",j,j)
          end
        end
      end
      d=d..a
      c=true
    end
    c=not c
  end
  return d
end

debug={
  on=false,
  log={}}

function dbg_show()
  if debug.on then
    for i=1,#debug.log do
      --rectfill(0, (i - 1) * 8, #debug.log[i] * 4, i * 8 - 1, 0)
      print(debug.log[i], 0, (i - 1) * 8, 10)
    end
  end
end

function dbg_add(txt) debug.log[#debug.log + 1] = txt end
function dbg_cls() debug.log = {} end

-->8
-- simplex noise

-- simplex noise example
-- by anthony digirolamo

local perms = {
   151, 160, 137, 91, 90, 15, 131, 13, 201, 95, 96, 53, 194, 233, 7, 225,
   140, 36, 103, 30, 69, 142, 8, 99, 37, 240, 21, 10, 23, 190, 6, 148,
   247, 120, 234, 75, 0, 26, 197, 62, 94, 252, 219, 203, 117, 35, 11, 32,
   57, 177, 33, 88, 237, 149, 56, 87, 174, 20, 125, 136, 171, 168, 68,   175,
   74, 165, 71, 134, 139, 48, 27, 166, 77, 146, 158, 231, 83, 111,   229, 122,
   60, 211, 133, 230, 220, 105, 92, 41, 55, 46, 245, 40, 244, 102, 143, 54,
   65, 25, 63, 161, 1, 216, 80, 73, 209, 76, 132, 187, 208, 89, 18, 169,
   200, 196, 135, 130, 116, 188, 159, 86, 164, 100, 109, 198, 173, 186, 3, 64,
   52, 217, 226, 250, 124, 123, 5, 202, 38, 147, 118, 126, 255, 82, 85, 212,
   207, 206, 59, 227, 47, 16, 58, 17, 182, 189, 28, 42, 223, 183, 170, 213,
   119, 248, 152, 2, 44, 154, 163, 70, 221, 153, 101, 155, 167, 43, 172, 9,
   129, 22, 39, 253, 19, 98, 108, 110, 79, 113, 224, 232, 178, 185, 112, 104,
   218, 246, 97, 228, 251, 34, 242, 193, 238, 210, 144, 12, 191, 179, 162, 241,
   81,   51, 145, 235, 249, 14, 239,   107, 49, 192, 214, 31, 181, 199, 106, 157,
   184, 84, 204, 176, 115, 121, 50, 45, 127, 4, 150, 254, 138, 236, 205, 93,
   222, 114, 67, 29, 24, 72, 243, 141, 128, 195, 78, 66, 215, 61, 156, 180
}

-- make perms 0 indexed
for i = 0, 255 do
   perms[i]=perms[i+1]
end

-- the above, mod 12 for each element --
local perms12 = {}

for i = 0, 255 do
   local x = perms[i] % 12
   perms[i + 256], perms12[i], perms12[i + 256] = perms[i], x, x
end

-- gradients for 2d, 3d case --
local grads3 = {
   { 1, 1, 0 }, { -1, 1, 0 }, { 1, -1, 0 }, { -1, -1, 0 },
   { 1, 0, 1 }, { -1, 0, 1 }, { 1, 0, -1 }, { -1, 0, -1 },
   { 0, 1, 1 }, { 0, -1, 1 }, { 0, 1, -1 }, { 0, -1, -1 }
}

for row in all(grads3) do
   for i=0,2 do
      row[i]=row[i+1]
   end
end

for i=0,11 do
   grads3[i]=grads3[i+1]
end

function getn2d (bx, by, x, y)
   local t = .5 - x * x - y * y
   local index = perms12[bx + perms[by]]
   return max(0, (t * t) * (t * t)) * (grads3[index][0] * x + grads3[index][1] * y)
end

-- @return noise value in the range [-1, +1]
function simplex2d (x, y)
   -- skew the input space to determine which simplex cell we are in.
   local s = (x + y) * 0.366025403 -- f
   local ix, iy = flr(x + s), flr(y + s)
   -- unskew the cell origin back to (x, y) space.
   local t = (ix + iy) * 0.211324865 -- g
   local x0 = x + t - ix
   local y0 = y + t - iy
   -- calculate the contribution from the two fixed corners.
   -- a step of (1,0) in (i,j) means a step of (1-g,-g) in (x,y), and
   -- a step of (0,1) in (i,j) means a step of (-g,1-g) in (x,y).
   ix, iy = band(ix, 255), band(iy, 255)
   local n0 = getn2d(ix, iy, x0, y0)
   local n2 = getn2d(ix + 1, iy + 1, x0 - 0.577350270, y0 - 0.577350270) -- g2
   -- determine other corner based on simplex (equilateral triangle) we are in
   local xi = 0
   if x0 >= y0 then xi = 1 end
   local n1 = getn2d(ix + xi, iy + (1 - xi), x0 + 0.211324865 - xi, y0 - 0.788675135 + xi) -- x0 + g - xi, y0 + g - (1 - xi)
   -- add contributions from each corner to get the final noise value.
   -- the result is scaled to return values in the interval [-1,1].
   return 70 * (n0 + n1 + n2)
end

__gfx__
0000000000d550000000000000000000000000000000000000000000000000000006600000066000000660000066660000000a9000000d0d0000c00000dddd00
0000050000dc000000000d0000d000000000050000000d000050000000d0000000656000000656000065560000655600000a990000d00f0f0000c0000dccccd0
0007dcd00dddf0000000dc50dddd00000007dcd00000dc500dcdf00005cd0000065566666666556006555560006556000a9999000ddd00f0000ccc00dccddccd
00fddd0000dcd700000cdd005cdc500500fddd00000cdd0000ddd70000ddd00065555556655555566555555666655666a9999000ddddd0f0000ccc00dcdccdcd
00ddc0000005dd0000dddf0050fdd5c500ddc00000dddf00000cdd00007cdd006555555665555556666556666555555600a99990ddddd00f00c7ccc0dcdcdccd
05cd000000005dd00dcd70000007ddd005cd00000dcd70000000dc50000fdcd0065566666666556000655600065555600a9999000ddd000f00c7ccc0dcdcccd0
00d000000000cd000050000000000d0000d000000050000000000d0000000500006560000006560000655600006556000a990000fdddffff000ccc00dccddd00
000000000005500000000000000000000000000000000000000000000000000000066000000660000066660000066000a90000000ffffff00000c0000dccc000
b3333b33b3bbbb3bc1cccc1c1c1111c1000000000000000000d55000000550000000000000000000000000000000000000000000000000000000000000000000
33333333bbb3bbbbccc1cccc111c111100000d0000000d0000dc000000dc00000000000000000000000000000000000000000000000000000000000000000000
33b33333b3bbb3b3c1ccc1c11c111c1c0007ddd00000dddd0dddf0000dd500000000000000000000000000000000000000000000000000000000000000000000
33333b33bbbb3bbbcccc1ccc1111c11150fdd5c55005cdc500dcd70000dd50000000000000000000000000000000000000000000000000000000000000000000
333333333bbbbb3b1ccccc1cc11111c15cdc50055c5ddf050005dd00007dcd000000000000000000000000000000000000000000000000000000000000000000
3b3333b3bb3b3bbbcc1c1ccc11c1c111dddd00000ddd700000005dd0000fddd00000000000000000000000000000000000000000000000000000000000000000
333333333bbbbb3b1ccccc1cc11111c100d0000000d000000000cd000000cd000000000000000000000000000000000000000000000000000000000000000000
33b33333bbb3bbbbccc1cccc111c111100000000000000000005500000055d000000000000000000000000000000000000000000000000000000000000000000
b3333b33b3bbbb3bc1cccc1c1c1111c1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333bbb3bbbbccc1cccc111c11110000050000000d000050000000d000000000000000000000000000000000000000000000000000000000000000000000
33b33333b3bbb3b3c1ccc1c11c111c1c000fdcd00000dc500dcd700005cd00000000000000000000000000000000000000000000000000000000000000000000
33333b33bbbb3bbbcccc1ccc1111c111007ddd00000cdd0000dddf0000ddd0000000000000000000000000000000000000000000000000000000000000000000
333333333bbbbb3b1ccccc1cc11111c100ddc00000ddd700000cdd0000fcdd000000000000000000000000000000000000000000000000000000000000000000
3b3333b3bb3b3bbbcc1c1ccc11c1c11105cd00000dcdf0000000dc500007dcd00000000000000000000000000000000000000000000000000000000000000000
333333333bbbbb3b1ccccc1cc11111c100d000000050000000000d00000005000000000000000000000000000000000000000000000000000000000000000000
33b33333bbb3bbbbccc1cccc111c1111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b3333b33b3bbbb3bc1cccc1c1c1111c100055d000005500000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333bbb3bbbbccc1cccc111c11110000cd000000cd0000d0000000d000000000000000000000000000000000000000000000000000000000000000000000
33b33333b3bbb3b3c1ccc1c11c111c1c000fddd000005dd00ddd7000dddd00000000000000000000000000000000000000000000000000000000000000000000
33333b33bbbb3bbbcccc1ccc1111c111007dcd000005dd005c5ddf055cdc50050000000000000000000000000000000000000000000000000000000000000000
333333333bbbbb3b1ccccc1cc11111c100dd500000dcd7005005cdc550fdd5c50000000000000000000000000000000000000000000000000000000000000000
3b3333b3bb3b3bbbcc1c1ccc11c1c1110dd500000dddf0000000dddd0007ddd00000000000000000000000000000000000000000000000000000000000000000
333333333bbbbb3b1ccccc1cc11111c100dc000000dc000000000d0000000d000000000000000000000000000000000000000000000000000000000000000000
33b33333bbb3bbbbccc1cccc111c11110005500000d5500000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000aaaa90000000000000000000000000000000000000000000000000000000000000000000000000000000000
00aaa900000000000000000000000000000000000aaaaaaaaaaa9000000000000000000000000000000000000000000000000000000000000000000000000000
00aaaa9000aa90aaaaaaa000aa0000aaaa0aaaaa000aaaaaaaaa9000000000000000000000000000000000000000000000000000000000000000000000000000
00aaaa9000aa90a888a88a00a8aa00aa8808a88a000000aa90000000000000000000000000000000000000000000000000000000000000000000000000000000
0000aa900aaa9aaa00a00a00a08a00aaaa00a00a00000aaa90000000000000000000000000000000000000000000000000000000000000000000000000000000
0000aa900aaa9a8800aaaa00aaaaa0a88800aaaaa0000aa900000000000000000000000000000000000000000000000000000000000000000000000000000000
0000aa90aaa9aa0000a888a0a888a0a00a00a888a000aaa900000000000000000000000000000000000000000000000000000000000000000000000000000000
000aaaaaaaa9aaa000a000a0aaaaa0aaaa0aa000a000aaa900000000000000000000000000000000000000000000000000000000000000000000000000000000
000aaaaaaa9088aa008000808888808888088000800aaa9000000000000000000000000000000000000000000000000000000000000000000000000000000000
00aaa900aa900088000000000000000000000000000aaa9000000000000000000000000000000000000000000000000000000000000000000000000000000000
0aaaa900aa900000000000000000000000000000000aa90000000000000000000000000000000000000000000000000000000000000000000000000000000000
0aaa9000aa900000000000000000000000000000000aa90000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000aa9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaaa99000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaaa99000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaaa99000000000000000000
00000aaaaaaa993b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3bb3b3b3b3b3b3b3b3b3b3b3b3b3b3b33333aaaaaaaaaaaaaaaaaaaaaaaaaaa990
00000aaaaaaa99bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3333aaaaaaaaaaaaaaaaaaaaaaaaaaa990
00000aaaaaaaaa999b3b3b3baaaaa99b3baaaaaaaaaaaaaaaa3b3b3b3baaaa3bb3b3b3b3aaaaaaaaa3b3aaaaaaaaaaaa3333333aaaaaaaaaaaaaaaaaaaaaa990
00000aaaaaaaaa999bbbbbbbaaaaa99bbbaaaaaaaaaaaaaaaabbbbbbbbaaaabbbbbbbbbbaaaaaaaaabbbaaaaaaaaaaaa3333333aaaaaaaaaaaaaaaaaaaaaa990
00000aaaaaaaaa999b3b3b3baaaaa99b3baa8888888aaa8888aaac1b3baa88aaaaa3b3b3aaaaa88883b388aaa8888aaab3b3b3b3b3b3b3aaaaa993b300000000
00000aaaaaaaaa999bbbbbbbaaaaa99bbbaa8888888aaa8888aaaccbbbaa88aaaaabbbbbaaaaa8888bbb88aaa8888aaabbbbbbbbbbbbbbaaaaa99bbb00000000
00000aaaaaaaaa999b3b3b3baaaaa99b3baa8888888aaa8888aaab3b3baa88aaaaa3b3b3aaaaa888833388aaa8888aaab3b3b3b3b3b3b3aaaaa993b300000000
00000bbbbbaaaa999bbbbbaaaaaaa99aaaaaaabbbbbaaabbbbaaabbbbbaabb888aabbbbbaaaaaaaaa33333aaabbb3aaabbbbbbbbbbbbaaaaaaa993bb00000000
00000b3b3caaaa999b3b3baaaaaaa99aaaaaaa3b3b3aaa3b3baaab3b3baa3b888aa3b3b3aaaaaaaaa33333aaa3333aaab3b3b3b3b3b3aaaaaaa9933300000000
00000bbbbcaaaa999bbbbbaaaaaaa99aaa8888bbbbbaaaaaaaaaabbbbbaaaaaaaaaaabbbaa888888833333aaaaaaaaaaaabbbbbbbbbbaaaaa993333300000000
00000b3b3caaaa999c1b3baaaaaaa99aaa88883b3b3aaaaaaaaaab3b3baaaaaaaaaaa3b3aa888888833333aaaaaaaaaaaab3b3b3b3b3aaaaa993333300000000
00000bbbbcaaaa999ccaaaaaaa999aaaaabbbbbbbbbaaa8888888aabbbaa8888888aabbbaabbbb3aa33333aaa8888888aabbbbbbbaaaaaaaa993333300000000
00000b3b3caaaa999c1aaaaaaa999aaaaa3b3b3b3b3aaa8888888aab3baa8888888aa3b3aa33b3baa33333aaa8888888aab3b3b3baaaaaaaa993b3b300000000
00000bbaaaaaaaaaaaaaaaaaaa999aaaaaaabbbbbbbaaabbbbbbbaabbbaaaaaaaaaaabbbaaaaaaaaa333aaaaa3333333aabbbbbbbaaaaaaaa993bbbb00000000
00000b3aaaaaaaaaaaaaaaaaaa999aaaaaaa3b3b3c1aaa3b3b3b3aab3baaaaaaaaaaa333aaaaaaaaa333aaaaa3333333aab3b3b3baaaaaaaa993b3b300000000
00000bbaaaaaaaaaaaaaaaaaaa999aaaaaaabbbbbccaaabbbbbbbaabbbaaaaaaaaaaab33aaaaaaaaa333aaaaa3333333aabbbbbbbaaaaaaaa99bbbbb00000000
00000b3aaaaaaaaaaaaaaaaa993b388888aaaa3b3b38883b3b3b388b3b8888888888833388888888833388888333333388b3b3baaaaaaa9993b3b3b300000000
00000bbaaaaaaaaaaaaaaaaa99bbb88888aaaabbbbb888bbbbbbb88bbb88888888888b33888888888b3388888333333388bbbbbaaaaaaa999bbbbbbb00000000
00000aaaaaaa991c1c1aaaaa993c1c1c1b88883b3b3b3b3b3b3b3b3b3b3b3b3bb3b3333333333333b3333333333333333333b3baaaaaaa9993b3b3b300000000
00000aaaaaaa99cccccaaaaa99bccccccb8888bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333333333333bb333333333333333333bbbaaaaaaa999bbbbbbb00000000
00aaaaaaaaaa991b3b3aaaaa993b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3bb3b333333333333333333333333333333333b3baaaaa99b3b3b3b3b300000000
00aaaaaaaaaa99cbbbbaaaaa99bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333333333333333333333333333333bbbaaaaa99bbbbbbbbbb00000000
00aaaaaaaaaa993b3b3aaaaa993b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3bb333333333333333333333b3b3b333333333b3baaaaa99b3b3b3333300000000
00aaaaaaaa99cbbbbbbaaaaa99bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333333333333333333bbbbbb33333333bbbaaaaa99bbbbbb333300000000
00aaaaaaaa991c1b3b3aaaaa993b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3333333333333333b3b333333333b3b3b33333333333baaaaa99b3b333333300000000
00000ccccccccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333333333333333bbbb33333333bbbbbb3333333333bbbbbbbbbbbb33333300000000
00000c1c1c1c1c1c1b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b333333333333333333b3b33333333333b3b3333333333333b3b3b3b3b333333300000000
00000ccccccccccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333333333333333bbbb3333333333bbbb333333333333bbbbbbbbbb33333300000000
00000c1c1c1c1c1c1b3b3b3b3b3c1c1b3b3b3b3b3b3b3b3b3b3b3b33333333333333333333b3b33333333333b3333333333333333333b3b3b333333300000000
00000ccccccccccccbbbbbbbbbbccccbbbbbbbbbbbbbbbbbbbbbbbb3333333333333333333bbbb3333333333bb333333333333333333bbbbbb33333300000000
00000b3b3b3c1c1c1b3b3b3b3c1c1c1c1b3b3b3b3b3b3b3b3b3b3333333333333333333333b3b333333333333333333333333333333333b3b3b3b3b300000000
00000bbbbbbccccccbbbbbbbbccccccccbbbbbbbbbbbbbbbbbbbb333333333333333333333bbbb33333333333333333333333333333333bbbbbbbbbb00000000
00000b3b3b3c1c1c1b3b3b3b3c1c1c1c1b3b3b3b3b3b3b3b333333333333333333333333333333333333333333333333333333333333b3b3b3b3b3b300000000
00000bbbbbbccccccbbbbbbbbccccccccbbbbbbbbbbbbbbbb33333333333333333333333333333333333333333333333333333333333bbbbbbbbbbbb00000000
00000b3b3b3b3c1c1b3b3b3c1c1c1c1b3b3b3b3b3b3b33333333333333333333333333333333333333333333333333333333333333b3b3b3b3b3b3b300000000
00000bbbbbbbbccccbbbbbbccccccccbbbbbbbbbbbbbb3333333333333333333333333333333333333333333333333333333333333bbbbbbbbbbbbbb00000000
00000c1b3b3b3b3b3b3b3c1c1c1c1b3b3b3b3b3b3b3b333333333333333333333333333333333333b3b3b33333333333333333b3b3b3b3b3b3b3b3b300000000
00000ccbbbbbbbbbbbbbbccccccccbbbbbbbbbbbbbbbb33333333333333333333333333333333333bbbbbb3333333333333333bbbbbbbbbbbbbbbbbb00000000
00000c1b3b3b3b3b3b3b3c1c1c1c1b3b3b3b3b3b3b3b3333333333333333333333333333333333b3b3b3b3b333333333333333b3b3b3b3b3b3b3b3b300000000
00000ccbbbbbbbbbbbbbbccccccccbbbbbbbbbbbbbbbb333333333333333333333333333333333bbbbbbbbbb33333333333333bbbbbbbbbbbbbbbbbb00000000
00000c1b3b3b3b3b3b3b3c1c1c1c1b3b3b3b3c1b3b3b3b33333333333333333333333333333333b3b3b3b3b33333333333333333b3b3b3b3b3b3b3b300000000
00000ccbbbbbbbbbbbbbbccccccccbbbbbbbbccbbbbbbbb3333333333333333333333333333333bbbbbbbbbb3333333333333333bbbbbbbbbbbbbbbb00000000
00000c1b3b3b3b3b3b3b3b3c1c1c1c1b3b3b3c1c1b3b3b3b333333333333333333333333333333b3b3b3b3b33333333333333333b3b3b3b3b3b3b3b300000000
00000ccbbbbbbbbbbbbbbbbccccccccbbbbbbccccbbbbbbbb33333333333333333333333333333bbbbbbbbbb3333333333333333bbbbbbbbbbbbbbbb00000000
00000c1b3b3b3b3b3b3b3b3b3c1c1c1b3c1c1c1c1c1c1b3b3b3b3b3b3b3b3b3bb3b3b3b3b3b333b3b33333333333333333333333b3b3b3b3b3b3b3b300000000
00000ccbbbbbbbbbbbbbbbbbbccccccbbccccccccccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33bbbb3333333333333333333333bbbbbbbbbbbbbbbb00000000
00000c1c1b3b3b3b3b3b3b3b3c1c1c1c1c1c1c1c1c1c1c1b3b3b3b3b3b3b3b3bb3b3b3b3b3b33333333333333333333333333333b3b3b3b3b333333300000000
00000ccccbbbbbbbbbbbbbbbbccccccccccccccccccccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3333333333333333333333333333bbbbbbbbbb33333300000000
00000c1c1c1b3b3b3b3b3b3b3b3b3c1c1c1c1c1c1c1c1c1b3b3b3b3b3b3b3b3bb3b3b3b3b3b333333333333333333333333333b3b3b3b3b3b333333300000000
00000ccccccbbbbbbbbbbbbbbbbbbccccccccccccccccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333333333333333333333333bbbbbbbbbbbb33333300000000
00000c1c1c1c1c1c1b3b3b3b3b3b3c1c1c11c1c1cc1c1b3b3b3b3b3b3b3b3b3bb3b3b3b3b3b3b3b333333333333333333333b3b3b3b3b3b33333333300000000
00000ccccccccccccbbbbbbbbbbbbcccccc111111ccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333333333333333333bbbbbbbbbbbb3333333300000000
00000c1c1c1c1c1c1c1b3b3b3b3b3c1c11c1c1c1cc1c1b3b3b3b3b3b3b3b3b3bb3b3b3b3b3b3b3b3b3b3b3b3333333333333b3b3b3b3b3b33333333300000000
00000ccccccccccccccbbbbbbbbbbcccc11111111ccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333333333333bbbbbbbbbbbb3333333300000000
00000c1c1c1c1c1c1c1b3b3b3b3c1c1c11c1c1c1cc1c1b3b3b3b3b3b3b3b3b3bb3b3b3b3b3b3b3b3b3b3b3b3b3b33333b3b3b3b3b3b3b3b33333333300000000
00000ccccccccccccccbbbbbbbbcccccc11111111ccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3333bbbbbbbbbbbbbbbb3333333300000000
00000b3c1c1c1c1c1c1c1b3c1c1c1c1c11c1c1c1cc1c1c1b3b3b3b3b3b3b3bcbb3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b33333333300000000
00000bbccccccccccccccbbcccccccccc11111111ccccccbbbbbbbbbbbbbbbcbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3333333300000000
00000bbccccccccccccccbbcccccccccc11111111ccccccbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3333333300000000
00000c1c1c1c1c1c1c1c1c1c1c1c1c1c11c1c1c1c1cc1c1c1b3b3b3b3b3b3b3bb3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3333333b300000000
00000cccccccccccccccccccccccccccc1111111111ccccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333333bb00000000
00000c1c1c1c1c1c1c1c1c1c1c1c1c1c11cc1c1c1c1c1c1c1b3b3b3b3b3b3b3bb3b3b3b3b3b3333333b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3333333b300000000
00000cccccccccccccccccccccccccccc11ccccccccccccccbbbbbbbbbbbbbbbbbbbbbbbbbbb333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333333bb00000000
00000c1c1c1c1c1c1c1c1c1c1c1c1c11cc1c1c1c1c1c1c1c1b3b3b3b3b3b3b3bb3b3b3b3b3b3333333b3b3b3b33333b3b3b3b3b3b3b3b3b3b3b3b3b300000000
00000cccccccccccccccccccccccccc11ccccccccccccccccbbbbbbbbbbbbbbbbbbbbbbbbbbb333333bbbbbbbb3333bbbbbbbbbbbbbbbbbbbbbbbbbb00000000
00000b3c1c1c1c1c1c1c1c1c1c1c11c1c1cc1c1b3b3c1c1b3b3b3b3b3b3b3b3bb3b3b3b3b3b333333333b3b33333333333b3b3b3b3b3b3b3b3b3b3b300000000
00000bbcccccccccccccccccccccc111111ccccbbbbccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333333bbbb3333333333bbbbbbbbbbbbbbbbbbbbbb00000000
00000b3c1c1c1c1c1c1c1c1c1c11c1c1c1cc1c1b3b3b3b3b3b3b3b3b3b3b3b3bb3b3b3b3b3b333333333b3b33333333333b3b3b3b3b3b3b3b3b3b3b300000000
00000bbcccccccccccccccccccc11111111ccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333333bbbb3333333333bbbbbbbbbbbbbbbbbbbbbb00000000
00000c1c1c1c1c1c1c1c1c1c11c1c1c1c1cc1c1b3b3b3b3b3b3b3b3b3b3b3b3bb3b3b3b3b3b33333333333333333333333b3b3b3b3b3b3b3b3b3b3b300000000
00000cccccccccccccccccccc1111111111ccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3333333333333333333333bbbbbbbbbbbbbbbbbbbbbb00000000
00000c1c1c1c1c1c1c1c1c1c11c1c1c1c1c1cc1c1c1c1b3b3b3b3b3b3b3b3b3bb3b3b3b33333333333333333333333b3b3b3b3b3b3b3b3b3b3b3b3b300000000
00000cccccccccccccccccccc111111111111ccccccccbbbbbbbbbbbbbbbbbbbbbbbbbbb3333333333333333333333bbbbbbbbbbbbbbbbbbbbbbbbbb00000000
00000c1c1c1c1c1b3b3c1c1c11c1c1c1c1c1c1c1cc1c1c1b3b3b3b3b3b3b3b3bb3b3333333333333333333333333b3b3b3b3b3b3b3b3b3b3b3b3b3b300000000
00000ccccccccccbbbbcccccc1111111111111111ccccccbbbbbbbbbbbbbbbbbbbbb333333333333333333333333bbbbbbbbbbbbbbbbbbbbbbbbbbbb00000000
00000c1c1c1c1b3b3b3c1c1c1c11c1c1c1c1c1c1c1cc1c1b3b3b3b3b3b3b3b3bb33333333333333333333333333333b3b3b3b3b3b3b3b3b3b3b3b3b300000000
00000ccccccccbbbbbbcccccccc1111111111111111ccccbbbbbbbbbbbbbbbbbbb3333333333333333333333333333bbbbbbbbbbbbbbbbbbbbbbbbbb00000000
00000c1c1c1c1c1c1c1c1c1c1c1c1c1c1c11c1c1cc1c1c1c1b3b3b3b3b3b3b3bb3b33333b3b333333333333333333333b3b3b3b3b3b3b3b3b3b3b3b300000000
00000cccccccccccccccccccccccccccccc111111ccccccccbbbbbbbbbbbbbbbbbbb3333bbbb33333333333333333333bbbbbbbbbbbbbbbbbbbbbbbb00000000
00000c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1b3b3b3b3b3b3b3bb3b3b3b3b3b3333333333333333333333333b3b3b3b3b3b3b3b3b3b300000000
00000ccccccccccccccccccccccccccccccccccccccccccccbbbbbbbbbbbbbbbbbbbbbbbbbbb333333333333333333333333bbbbbbbbbbbbbbbbbbbb00000000
00000c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1b3b3b3b3b3b3bb3b3b3b3b3b3b333333333333333333333333333b3b3b3b3b3b3b3b300000000
00000ccccccccccccccccccccccccccccccccccccccccccccccbbbbbbbbbbbbbbbbbbbbbbbbbbb33333333333333333333333333bbbbbbbbbbbbbbbb00000000
00000c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1b3b3b3b3b3bb3b3b3b3b3b3b333333333333333333333333333b3b3b33333b3b3b300000000
00000ccccccccccccccccccccccccccccccccccccccccccccccccbbbbbbbbbbbbbbbbbbbbbbbbb33333333333333333333333333bbbbbb3333bbbbbb00000000
00000c1c1c1c1c1c1c11c1c1cc1c1c1c1c1c1c1c1c1c1c1c1c1c1b3b3b3b3b3bb3b3b3b3b3b3b3b333b3b3b3b3b3b33333333333b3b3b3333333333300000000
00000cccccccccccccc111111ccccccccccccccccccccccccccccbbbbbbbbbbbbbbbbbbbbbbbbbbb33bbbbbbbbbbbb3333333333bbbbbb333333333300000000
00000b3b3c1c1c1c1c1c11cc1c1c1c1c1c1c1c1c1c1c1c1c1c1b3b3b3b3b3b3bb3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b333333333b3b333333333333300000000
00000bbbbcccccccccccc11ccccccccccccccccccccccccccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333333bbbb33333333333300000000
00000b3b3b3c1c1c1c1c1c1c1c1c1c1c1c1c1c1b3b3b3b3b3b3b3b3b3b3b3b3bb3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b333333333b3b333333333333300000000
00000bbbbbbccccccccccccccccccccccccccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333333bbbb33333333333300000000
00000c1c1c1c1c1c1c1c1c1c1b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3bb3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3333333333333333333333300000000
00000ccccccccccccccccccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333333333333333333333300000000
00000c1c1c1c11c1c1cc1c1b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3bb3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b33333333333333333333300000000
00000cccccccc111111ccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3333333333333333333300000000
000001c1c1c1c1c1c1c1cc1c1b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3bb3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b333333333333333333300000000
000001111111111111111ccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333333333333333300000000
000001c1c1c1c1c1c1c1c1cc1c1c1b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3bb3b3b3b3b3b3b3b3b3b3b3b3b3b3b33333b3b3b3333333333333333300000000
00000111111111111111111ccccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3333bbbbbb333333333333333300000000
00000c11c1c1c1c1c1c1c1c1cc1c1c1c1b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3bb3b3b3b3b3b3b3b3b3b3b3b3b3b333333333b3b3333333333333333300000000
00000cc111111111111111111ccccccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333333bbbb333333333333333300000000
00000c1c11c1c1c1c1c1c1c1c1c1c1cc1c1c1c1b3b3b3b3b3b3b3b3b3b3b3b3bb3b3b3b3b3b3b3b3b3b3b3b3b3b333333333b3b3b3333333333333b300000000
00000cccc1111111111111111111111ccccccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333333bbbbbb333333333333bb00000000
00000c1c1c11c1c1c1c1c1c1c1c1c1c1c1cc1c1c1c1c1b3b3b3b3b3b3b3b3b3bb3b3b3b3b3b3b3b3b3b3b3b3b33333333333b3b3b33333333333333300000000
00000cccccc111111111111111111111111ccccccccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3333333333bbbbbb3333333333333300000000
00000c1c1c11c1c1c1c1c1c1c1c1c1c1c1cc1c1c1c1c1c1c1c1b3b3b3b3b3b3bb3b3b3b3b3b3b3b3b3b3b3b333333333333333b3b3b3b3333333333300000000
00000cccccc111111111111111111111111ccccccccccccccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333333333333bbbbbbbb333333333300000000
00000c1c1c11c1c1c1c1c1c1c1cc1c1c1c1c1c1c1c1c1c1c1c1c1b3b3b3b3b3bb3b3b3b3b3b3b3b3b333333333333333333333b3b3b3b3333333333300000000
00000cccccc1111111111111111ccccccccccccccccccccccccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333333333333333333bbbbbbbb333333333300000000
00000c1c1c1c1c11c1c1c1cc1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1b3b3b3b3bb3b3b3b3b3b3b3b333333333333333333333b3b3b3b3b3333333333300000000
00000cccccccccc11111111ccccccccccccccccccccccccccccccccbbbbbbbbbbbbbbbbbbbbbbbbb33333333333333333333bbbbbbbbbb333333333300000000
00000c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c11c1cc1c1b3b3b3b3b3b3b3bb3b3b3b3b3b3b3b333333333333333333333b3b3b3b333333333333300000000
00000cccccccccccccccccccccccccccccccccccc1111ccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333333333333333333bbbbbbbb33333333333300000000
00000c1c1c1c1b3b3b3c1c1c1c1c1c1c1c1c1c1c11c1cc1c1b3b3b3b3b3b3b3bb3b3b3b3b3b33333333333333333333333b3b3b3b33333333333333300000000
00000ccccccccbbbbbbcccccccccccccccccccccc1111ccccbbbbbbbbbbbbbbbbbbbbbbbbbbb3333333333333333333333bbbbbbbb3333333333333300000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

