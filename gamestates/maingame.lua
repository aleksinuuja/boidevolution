gameStates.maingame = {}
s = gameStates.maingame -- short ref to maingame state
s.isInitiated = false

require "boid"
require "foodbit"
require "egg"
require "slider"
require "inspector"
require "foodticker"
require "rulepercentages"
require "textlogger"

function gameStates.maingame.initiateState()
  s.resetGame()
end

function s.resetGame()
  s.isPaused = false
  s.isControlsDisabled = false
  scrolloffsetX = 0
	scrolloffsetY = 0

	boids = {}
  selectedBoid = 0
  isFollowingSelectedBoid = true
  raceCounter = {0, 0, 0, 0}
  racesAlive = 0

  foodBits = {}
  eggs = {}

  timeScaleSlider = Slider:new({
    x = 600,
    y = 10,
    width = 100,
    valuesUpTo = 1000
  })

  zoomSlider = Slider:new({
    x = 800,
    y = 10,
    width = 100,
    valuesUpTo = 20
  })

  inspector = Inspector:new({
    x = 1000,
    y = 200
  })

  textLogger = Textlogger:new({
		maxrows = 3,
	  rowheight = 20,
		textsize = 12,
	  updateSpeed = 3, -- seconds (how often log scrolls on it's own)
	  x = 10,
	  y = love.graphics.getHeight() - 100,
		blinkDuration = 0.050, -- milliseconds how quickly new message blinks
	  maxBlinks = 3})

  -- -- gene value ranges, low - high - normal
  gene_rule_random_range = {lo=0, hi=10, no=0, best=0} -- range 0-10
  gene_rule_towardsFlockCenter_range = {lo=0, hi=2, no=0.6, best=0} -- range 0-2
  gene_rule_keepDistance_range = {lo=0, hi=2, no=1, best=0} -- range 0-2
  gene_rule_keepDistance_distance_range = {lo=100, hi=2500, no=500, best=0} -- range 100-2500
  gene_rule_align_range = {lo=0, hi=2, no=1, best=0} -- range 0-2
  gene_rule_avertEnemies_range = {lo=-2, hi=2, no=0.2, best=0} -- range -2 - 2
  gene_rule_avertEnemies_distance_range = {lo=100, hi=5000, no=1000, best=0} -- range 100-5000
  gene_rule_searchFood_range = {lo=0, hi=2, no=0.5, best=0} -- range 0-2
  gene_rule_searchFood_distance_range = {lo=100, hi=5000, no=1000, best=0} -- range 100-5000
  gene_rule_searchEggs_range = {lo=0, hi=2, no=0.5, best=0} -- range 0-2
  gene_rule_searchEggs_distance_range = {lo=100, hi=5000, no=2000, best=0} -- range 100-5000


  MaxFoodBits = 2000

  function createEgg(parent)
    -- this is where the magic happens
    -- the egg genes get random mutations

    local i
    local mutations = {}
    for i=1,11 do
      table.insert(mutations, math.random(3)-2) -- now every mutation is -1, 0 or +1
    end

    table.insert(eggs, Egg:new({
      gene_rule_random = parent.gene_rule_random + mutations[1],
      gene_rule_towardsFlockCenter = parent.gene_rule_towardsFlockCenter + mutations[2],
      gene_rule_keepDistance = parent.gene_rule_keepDistance + mutations[3],
      gene_rule_align = parent.gene_rule_align + mutations[4],
      gene_rule_avertEnemies = parent.gene_rule_avertEnemies + mutations[5],
      gene_rule_keepDistance_distance = parent.gene_rule_keepDistance_distance + mutations[6],
      gene_rule_avertEnemies_distance = parent.gene_rule_avertEnemies_distance + mutations[7],
      gene_rule_searchFood = parent.gene_rule_searchFood + mutations[8],
      gene_rule_searchFood_distance = parent.gene_rule_searchFood_distance + mutations[9],
      gene_rule_searchEggs = parent.gene_rule_searchEggs + mutations[10],
      gene_rule_searchEggs_distance = parent.gene_rule_searchEggs_distance + mutations[11],
      race = parent.race,
      x = parent.x,
      y = parent.y
    }))
    if raceCounter[parent.race] == 0 then racesAlive = racesAlive + 1 end
    raceCounter[parent.race] = raceCounter[parent.race] + 1
  end

  function createFood()
    if #foodBits < MaxFoodBits then
      local xr = math.random()*universe.width
      local yr = math.random()*universe.height
      table.insert(foodBits, FoodBit:new({
        x = xr,
        y = yr
      }))
    end
  end
  foodTicker = FoodTicker:new({ tickFunction = createFood })
  for i=1,1000 do createFood() end -- initial food on the map

  initBoids(false)
end

function initBoids(isPreviousBest)
  local i
  if isPreviousBest then
    for i=1,30 do
      createBoid(true)
    end
  else
    for i=1,30 do
      createBoid(false)
    end
  end
end


function gameStates.maingame.draw()
  -- first draw zoomable game graphics
  love.graphics.push()
  love.graphics.setColor(255, 255, 255)
  love.graphics.setLineWidth(1)
  love.graphics.scale(tv("scale"), tv("scale"))
  love.graphics.translate(scrolloffsetX, scrolloffsetY)

  -- draw background image which is as large as the game universe
  love.graphics.draw(bg, 0, 0, 0, UNIVERSESIZE, UNIVERSESIZE)

  drawBoids()
  drawFoodBits()
  drawEggs()

  -- then reset transformations and draw static overlay graphics such as texts and menus
  love.graphics.pop()
  textLogger:draw()
  timeScaleSlider:draw()
  zoomSlider:draw()
  inspector:draw()

  love.graphics.setColor(255, 255, 255)
  love.graphics.print("Current FPS: " .. tostring(currentFPS) .. ", Timescale: "
    .. tostring(timeScale) .. ", Boid count: " .. #boids
    .. ", SCALE: " .. tweenEngine:returnValue("scale")
    .. ", #foodBits: " .. #foodBits, 10, 10)
  love.graphics.print("Red: " .. raceCounter[1]
    .. ", Yellow: " .. raceCounter[2]
    .. ", Blue: " .. raceCounter[3]
    .. ", Green: " .. raceCounter[4]
    .. ", racesAlive: " .. racesAlive, 10, 30)
--  love.graphics.print("scrolloffsetX: " .. tostring(scrolloffsetX) .. ", scrolloffsetY: " .. tostring(scrolloffsetY), 10, 30)
end


function drawBoids()
		for i, o in ipairs(boids) do
		  o:drawShadow()
		end
    for i, o in ipairs(boids) do
			o:draw()
		end
end

function drawFoodBits()
		for i, o in ipairs(foodBits) do
      o:draw()
		end
end

function drawEggs()
		for i, o in ipairs(eggs) do
      o:draw()
		end
end

function gameStates.maingame.mousepressed(x, y, button)
  if button == 1 then
    -- timeScaleSlider dragging
    if x > timeScaleSlider.rect.x and x < timeScaleSlider.rect.x + timeScaleSlider.rect.width
    and y > timeScaleSlider.rect.y and y < timeScaleSlider.rect.y + timeScaleSlider.rect.height
    then
      timeScaleSlider.dragging.active = true
      timeScaleSlider.dragging.diffX = x - timeScaleSlider.rect.x
      timeScaleSlider.dragging.diffY = y - timeScaleSlider.rect.y
    -- zoomSlider dragging
    elseif x > zoomSlider.rect.x and x < zoomSlider.rect.x + zoomSlider.rect.width
    and y > zoomSlider.rect.y and y < zoomSlider.rect.y + zoomSlider.rect.height
    then
      zoomSlider.dragging.active = true
      zoomSlider.dragging.diffX = x - zoomSlider.rect.x
      zoomSlider.dragging.diffY = y - zoomSlider.rect.y
    -- inspector close button
    elseif x > inspector.close.x and x < inspector.close.x + inspector.close.width
    and y > inspector.close.y and y < inspector.close.y + inspector.close.height
    then
      inspector.isVisible = false
      if selectedBoid > 0 then boids[selectedBoid].isSelected = false end
      isFollowingSelectedBoid = false
    -- inspector next button
    elseif x > inspector.next.x and x < inspector.next.x + inspector.next.width
    and y > inspector.next.y and y < inspector.next.y + inspector.next.height
    then
      if selectedBoid > 0 then
        boids[selectedBoid].isSelected = false
        selectedBoid = selectedBoid + 1
        if selectedBoid > #boids then selectedBoid = 1 end
        boids[selectedBoid].isSelected = true
      end
    -- inspector prev button
    elseif x > inspector.prev.x and x < inspector.prev.x + inspector.prev.width
    and y > inspector.prev.y and y < inspector.prev.y + inspector.prev.height
    then
      if selectedBoid > 0 then
        boids[selectedBoid].isSelected = false
        selectedBoid = selectedBoid - 1
        if selectedBoid == 0 then selectedBoid = #boids end
        boids[selectedBoid].isSelected = true
      end
    -- inspector dragging
    elseif x > inspector.x and x < inspector.x + inspector.width
    and y > inspector.y and y < inspector.y + 30
    then
      inspector.dragging.active = true
      inspector.dragging.diffX = x - inspector.x
      inspector.dragging.diffY = y - inspector.y
    else -- not clicked on any draggable, so this is select boids
      local c = selectClosestBoid(x, y)
      if c > 0 then
        if selectedBoid > 0 then boids[selectedBoid].isSelected = false end
        boids[c].isSelected = true
        inspector.isVisible = true
        selectedBoid = c
        isFollowingSelectedBoid = true
      end
    end
  end
end

-- returns the boids-array index of the closest boid
function selectClosestBoid(x, y)
  x = x / tv("scale") - scrolloffsetX
  y = y / tv("scale") - scrolloffsetY
  local i, o, deltaX, deltaY, distance
  -- start from high value to find lowest value
  local smallestDistance = math.sqrt(universe.width*universe.width + universe.height*universe.height)
  local chosenBoidIndex = 0

  for i, o in ipairs(boids) do
    deltaX = math.abs(o.x - x)
    deltaY = math.abs(o.y - y)
    distance = math.sqrt(deltaX*deltaX + deltaY*deltaY)
    if distance < smallestDistance then
      smallestDistance = distance
      chosenBoidIndex = i
    end
  end
  return chosenBoidIndex
end

function gameStates.maingame.mousereleased(x, y, button)
  if button == 1 then
    -- reset dragging for all sliders
    timeScaleSlider.dragging.active = false
    zoomSlider.dragging.active = false
    inspector.dragging.active = false
  end
end

function gameStates.maingame.keypressed(key)
  if key == "space" then
    s.isPaused = not(s.isPaused) -- switch pause on and off
--  elseif key == "b" then
--    table.insert(boids, Boid:new({x = math.random()*universe.width, y = math.random()*universe.height}))
  elseif key == "z" then
    if timeScale > 1 then timeScale = timeScale - 1 end
  elseif key == "x" then
    timeScale = timeScale + 1
  end
end

function gameStates.maingame.update(dt)
  if not isInitiated then
    isInitiated = true
    gameStates.maingame.initiateState()
  end

  if not s.isPaused then
    if love.keyboard.isDown("b") then
      createBoid(false)
    end


    timeScaleSlider:update()
    timeScale = timeScaleSlider.value

    zoomSlider:update()
    tweenEngine:setValue("scale", (zoomSlider.value-1)/100 + love.graphics.getWidth() / universe.width)

    inspector:update()
    foodTicker:update()
    textLogger:update()

    -- update camera position
    if isFollowingSelectedBoid and selectedBoid > 0 then
      centerCameraOffsets(boids[selectedBoid].x, boids[selectedBoid].y)
    else
      updateCameraOffsetsByMouse(love.mouse.getPosition())
    end

  	local i, o
    -- update boids:
  	for i, o in ipairs(boids) do
  		o:update(dt, i)
  		if o.removeMe then
        if i == selectedBoid then
          selectedBoid = 0
          isFollowingSelectedBoid = false
          inspector.isVisible = false
        elseif i < selectedBoid then
          selectedBoid = selectedBoid -1
        end -- bug fix: update index of selected boid
        raceCounter[o.race] = raceCounter[o.race] - 1

        if raceCounter[o.race] == 0 then
          racesAlive = racesAlive - 1
          if o.race == 1 then textLogger:newMessage("Red boids are extinct!", "red") end
          if o.race == 2 then textLogger:newMessage("Yellow boids are extinct!", "red") end
          if o.race == 3 then textLogger:newMessage("Blue boids are extinct!", "red") end
          if o.race == 4 then textLogger:newMessage("Green boids are extinct!", "red") end
          if racesAlive == 1 then
            takeWinnerGenes()
            initBoids(true)
          end

        end
        table.remove(boids, i)
      end
  	end
    -- update foodBits:
  	for i, o in ipairs(foodBits) do
  		o:update()
  	end
    -- update foodBits:
  	for i, o in ipairs(eggs) do
  		o:update()
  		if o.removeMe then table.remove(eggs, i) end
  	end

    -- check collisions
    -- boids hitting food
    for i, boid in ipairs(boids) do
      for j, foodBit in ipairs(foodBits) do
        if CheckCollision(boid.x-50, boid.y-50, 100, 100, foodBit.x, foodBit.y, 50, 50) then
          table.remove(foodBits, j)
          boid.energy = boid.energy + 50
          if boid.energy > BoidMaxEnergy then boid.energy = BoidMaxEnergy end
        end
      end
    end

    -- boids hitting eggs
    for i, boid in ipairs(boids) do
      for j, egg in ipairs(eggs) do
        if CheckCollision(boid.x-50, boid.y-50, 100, 100, egg.x, egg.y, 50, 50) then
          if boid.race ~= egg.race then
            table.remove(eggs, j)
            raceCounter[egg.race] = raceCounter[egg.race] - 1
            if raceCounter[egg.race] == 0 then
              racesAlive = racesAlive - 1
              if egg.race == 1 then textLogger:newMessage("Red boids are extinct!", "red") end
              if egg.race == 2 then textLogger:newMessage("Yellow boids are extinct!", "red") end
              if egg.race == 3 then textLogger:newMessage("Blue boids are extinct!", "red") end
              if egg.race == 4 then textLogger:newMessage("Green boids are extinct!", "red") end
            end
            if racesAlive == 1 then
              takeWinnerGenes()
              initBoids(true)
            end

            boid.energy = boid.energy + 100
            if boid.energy > BoidMaxEnergy then boid.energy = BoidMaxEnergy end
          end
        end
      end
    end

  end -- is not paused
end

function takeWinnerGenes()
  print("The winning race's genes are copied to other races.")
  textLogger:newMessage("The winning race's genes are copied to other races.", "green")
  gene_rule_random_range.best = boids[1].gene_rule_random
  gene_rule_towardsFlockCenter_range.best = boids[1].gene_rule_towardsFlockCenter
  gene_rule_keepDistance_range.best = boids[1].gene_rule_keepDistance
  gene_rule_align_range.best = boids[1].gene_rule_align
  gene_rule_avertEnemies_range.best = boids[1].gene_rule_avertEnemies
  gene_rule_keepDistance_distance_range.best = boids[1].gene_rule_keepDistance_distance
  gene_rule_avertEnemies_distance_range.best = boids[1].gene_rule_avertEnemies_distance
  gene_rule_searchFood_range.best = boids[1].gene_rule_searchFood
  gene_rule_searchFood_distance_range.best = boids[1].gene_rule_searchFood_distance
  gene_rule_searchEggs_range.best = boids[1].gene_rule_searchEggs
  gene_rule_searchEggs_distance_range.best = boids[1].gene_rule_searchEggs_distance
end

function createBoid(isPreviousBest)
  local race
  if not isPreviousBest then
    race = math.random(4)
    if raceCounter[race] == 0 then racesAlive = racesAlive + 1 end
    raceCounter[race] = raceCounter[race] + 1
    textLogger:newMessage("Created new boid!", "green")
    table.insert(boids, Boid:new({
      race = race,
      gene_rule_random = getNormalValueAsPercentage(gene_rule_random_range, false),
      gene_rule_towardsFlockCenter = getNormalValueAsPercentage(gene_rule_towardsFlockCenter_range, false),
      gene_rule_keepDistance = getNormalValueAsPercentage(gene_rule_keepDistance_range, false),
      gene_rule_align = getNormalValueAsPercentage(gene_rule_align_range, false),
      gene_rule_avertEnemies = getNormalValueAsPercentage(gene_rule_avertEnemies_range, false),
      gene_rule_keepDistance_distance = getNormalValueAsPercentage(gene_rule_keepDistance_distance_range, false),
      gene_rule_avertEnemies_distance = getNormalValueAsPercentage(gene_rule_avertEnemies_distance_range, false),
      gene_rule_searchFood = getNormalValueAsPercentage(gene_rule_searchFood_range, false),
      gene_rule_searchFood_distance = getNormalValueAsPercentage(gene_rule_searchFood_distance_range, false),
      gene_rule_searchEggs = getNormalValueAsPercentage(gene_rule_searchEggs_range, false),
      gene_rule_searchEggs_distance = getNormalValueAsPercentage(gene_rule_searchEggs_distance_range, false),
      x = math.random()*universe.width,
      y = math.random()*universe.height}))
  else -- use surviving "best" race genes as a base for genes
    print("now taking the winner genes for a new boid")
    race = math.random(4)
    if raceCounter[race] == 0 then racesAlive = racesAlive + 1 end
    raceCounter[race] = raceCounter[race] + 1
    textLogger:newMessage("Created new boid!", "green")
    table.insert(boids, Boid:new({
      race = race,
      gene_rule_random = gene_rule_random_range.best,
      gene_rule_towardsFlockCenter = gene_rule_towardsFlockCenter_range.best,
      gene_rule_keepDistance = gene_rule_keepDistance_range.best,
      gene_rule_align = gene_rule_align_range.best,
      gene_rule_avertEnemies = gene_rule_avertEnemies_range.best,
      gene_rule_keepDistance_distance = gene_rule_keepDistance_distance_range.best,
      gene_rule_avertEnemies_distance = gene_rule_avertEnemies_distance_range.best,
      gene_rule_searchFood = gene_rule_searchFood_range.best,
      gene_rule_searchFood_distance = gene_rule_searchFood_distance_range.best,
      gene_rule_searchEggs = gene_rule_searchEggs_range.best,
      gene_rule_searchEggs_distance = gene_rule_searchEggs_distance_range.best,
      x = math.random()*universe.width,
      y = math.random()*universe.height}))
  end
end

-- Collision detection taken function from http://love2d.org/wiki/BoundingBox.lua
-- Returns true if two boxes overlap, false if they don't
-- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- x2,y2,w2 & h2 are the same, but for the second box
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function updateCameraOffsetsByMouse(x, y) -- gets x and y value from mouse
  local screenwidth = (love.graphics.getWidth() / tv("scale")) -- how much of the universe is visible right now
	local screenheight = (love.graphics.getHeight() / tv("scale"))
  local scrollBoundary = 100
  local scrollSpeed = 10
  -- scrolling left
  if (x < scrollBoundary and x >= 0) then
    local edgeAccelerate = math.max(((scrollBoundary - x))-scrollBoundary/2, 0)
    scrollSpeed = scrollSpeed + edgeAccelerate/2 -- faster scrolling closer to edge
    scrolloffsetX = scrolloffsetX + scrollSpeed*5
  end
  -- scrolling right
  if (x > (love.graphics.getWidth() - scrollBoundary) and x <= love.graphics.getWidth()) then
    local edgeAccelerate = math.max(scrollBoundary - (love.graphics.getWidth() - x)-scrollBoundary/2, 0)
    scrollSpeed = scrollSpeed + edgeAccelerate/2 -- faster scrolling closer to edge
    scrolloffsetX = scrolloffsetX - scrollSpeed*5
  end
  -- scrolling up
  if (y < scrollBoundary and y >= 0) then
    local edgeAccelerate = math.max(((scrollBoundary - y))-scrollBoundary/2, 0)
    scrollSpeed = scrollSpeed + edgeAccelerate/2 -- faster scrolling closer to edge
    scrolloffsetY = scrolloffsetY + scrollSpeed*5
  end
  -- scrolling down
  if (y > (love.graphics.getHeight() - scrollBoundary) and y <= love.graphics.getHeight()) then
    local edgeAccelerate = math.max(scrollBoundary - (love.graphics.getHeight() - y)-scrollBoundary/2, 0)
    scrollSpeed = scrollSpeed + edgeAccelerate/2 -- faster scrolling closer to edge
    scrolloffsetY = scrolloffsetY - scrollSpeed*5
  end
  -- don't allow showing black space - stop scroll at boundaries - fix offset when zooming
  if scrolloffsetX > 0 then scrolloffsetX = 0 end
  if scrolloffsetY > 0 then scrolloffsetY = 0 end
  if -scrolloffsetX > universe.width-screenwidth then scrolloffsetX = -(universe.width-screenwidth) end
  if -scrolloffsetY > universe.height-screenheight then scrolloffsetY = -(universe.height-screenheight) end

end

-- center camera to x, y by calculating correct scrolloffset
-- except when close to universe boundaries
function centerCameraOffsets(x, y)

	local screenwidth = (love.graphics.getWidth() / tv("scale"))
	local screenheight = (love.graphics.getHeight() / tv("scale"))
	local midpointx = - scrolloffsetX + (screenwidth  / 2)
	local midpointy = - scrolloffsetY + (screenheight / 2)

	-- so the delta to move scrolloffset is the difference between where the ship is drawn and the midpoint
	local deltax = midpointx - x
	local deltay = midpointy - y

	-- calculate distance from universe edge
	local xdistance = universe.width - midpointx
	local ydistance = universe.height - midpointy

	-- determine if ship coordinates are near boundary or in the middle - this affects scrolling
	-- values as strings "start", "mid", "end"
	local xarea = "mid"
	local yarea = "mid"
	if x < (screenwidth / 2) then xarea = "start" end
	if x > (universe.width - (screenwidth / 2)) then xarea = "end" end
	if y < (screenheight / 2) then yarea = "start" end
	if y > (universe.height - (screenheight / 2)) then yarea = "end" end

	-- in mid area, scroll freely
	if xarea == "mid" then scrolloffsetX = scrolloffsetX + deltax end
	if yarea == "mid" then scrolloffsetY = scrolloffsetY + deltay end

	-- if close to zero, that is "start", do nothing, offset remains put

	-- if close to end of universe boundary, that is "end" calculate correct offset
	-- it's universe boundary - screenwidth/height
	if xarea == "end" then scrolloffsetX = - (universe.width - screenwidth) end
	if yarea == "end" then scrolloffsetY = - (universe.height - screenheight) end

  if not(tv("scale") >= (love.graphics.getWidth() / universe.width)) then
		-- if scale is so zoomed out that the universe width is smaller in width than the screen, center it
		local actualWidthOfUniverse = universe.width*tv("scale")
		local centerXDelta = (love.graphics.getWidth() - actualWidthOfUniverse)/2
		scrolloffsetX = centerXDelta/tv("scale")
	end

end

-- return 'v' rounded to 'p' decimal places:
function round(v, p)
local mult = math.pow(10, p or 0) -- round to 0 places when p not supplied
    return math.floor(v * mult + 0.5) / mult;
end
