gameStates.maingame = {}
s = gameStates.maingame -- short ref to maingame state
s.isInitiated = false

require "boid"
require "slider"
require "inspector"
-- require "rule"  TO BE DONE

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

  timeScaleSlider = Slider:new({
    x = 600,
    y = 10,
    width = 100,
    valuesUpTo = 100
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

  -- then reset transformations and draw static overlay graphics such as texts and menus
  love.graphics.pop()
  timeScaleSlider:draw()
  zoomSlider:draw()
  inspector:draw()

  love.graphics.setColor(255, 255, 255)
  love.graphics.print("Current FPS: " .. tostring(currentFPS) .. ", Timescale: "
    .. tostring(timeScale) .. ", Boid count: " .. #boids
    .. ", SCALE: " .. tweenEngine:returnValue("scale"), 10, 10)
  love.graphics.print("scrolloffsetX: " .. tostring(scrolloffsetX) .. ", scrolloffsetY: " .. tostring(scrolloffsetY), 10, 30)
end


function drawBoids()
		for i, o in ipairs(boids) do
			o:drawShadow()
		end
    for i, o in ipairs(boids) do
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
      end
    end
  end
end

-- returns the boids-array index of the closest boid
function selectClosestBoid(x, y)
  x = x / tv("scale")
  y = y / tv("scale")
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
      table.insert(boids, Boid:new({x = math.random()*universe.width, y = math.random()*universe.height}))
    end


    timeScaleSlider:update()
    timeScale = timeScaleSlider.value

    zoomSlider:update()
    tweenEngine:setValue("scale", (zoomSlider.value-1)/100 + love.graphics.getWidth() / universe.width)

    inspector:update()

    -- update camera position
    if isFollowingSelectedBoid and selectedBoid > 0 then
      centerCameraOffsets(boids[selectedBoid].x, boids[selectedBoid].y)
    else
      updateCameraOffsetsByMouse(love.mouse.getPosition())
    end

    -- update boids:
  	local i, o
  	for i, o in ipairs(boids) do
  		o:update(dt, i)
  		if o.removeMe then table.remove(boids, i) end
  	end
  end
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
