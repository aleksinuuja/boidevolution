gameStates.maingame = {}
s = gameStates.maingame -- short ref to maingame state
s.isInitiated = false

require "boid"

function gameStates.maingame.initiateState()
  s.resetGame()
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
  love.graphics.print("Current FPS: " .. tostring(currentFPS), 10, 10)
end


function drawBoids()
		for i, o in ipairs(boids) do
			o:draw()
		end
end

function drawOverlay() -- called from substates getready and gameover
  love.graphics.setColor(0, 0, 0, 150)
  love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
end

function gameStates.maingame.keypressed(key)
  if key == "space" then
    s.isPaused = not(s.isPaused) -- switch pause on and off
  elseif key == "b" then
    table.insert(boids, Boid:new({x = math.random()*universe.width, y = math.random()*universe.height}))
  elseif key == "2" then
    local currentScale = tv("scale")
    if not(currentScale == love.graphics.getHeight() / universe.height) then
      tweenEngine:createTween("scale", currentScale, 2, 0.5, easeOutQuint)
    end
  elseif key == "1" then
    local currentScale = tv("scale")
    if not(currentScale == love.graphics.getWidth() / universe.width) then
      tweenEngine:createTween("scale", currentScale, love.graphics.getWidth() / universe.width, 0.5, easeOutQuint)
    end
  end
end

function gameStates.maingame.update(dt)
  if not isInitiated then
    isInitiated = true
    gameStates.maingame.initiateState()
  end

  if not s.isPaused then
    -- update camera position
    calculateOffsets(universe.width/2, universe.height/2)

    -- update boids:
  	local i, o
  	for i, o in ipairs(boids) do
  		o:update(dt)
  		if o.removeMe then table.remove(itemPacks, i) end
  	end
  end
end


-- center camera to x, y by calculating correct scrolloffset
-- except when close to universe boundaries
function calculateOffsets(x, y)

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

function s.resetGame()
  s.isPaused = false
  s.isControlsDisabled = false
  scrolloffsetX = 0
	scrolloffsetY = 0

	boids = {}
end
