require 'tween2'

function love.load()
	math.randomseed(os.time())

	UNIVERSESIZE = 10 -- factor to scale bg image with
	FrictionMultiplier = 5
	FrictionLimitVelocity = 100
	timeScale = 1 -- number of updates before drawing

  bg = love.graphics.newImage("graphics/bigbg.jpg")

	universe = {
		width = bg:getWidth() * UNIVERSESIZE,
		height = bg:getHeight() * UNIVERSESIZE
	}

	tweenEngine = Tween:new()
	initiateTweenValues()

	-- initiate state handling
	gameStates = {}
	stateTimeStamp = 0
	timeInState = 0
	gotoGameState("maingame")
	currentSubState = "none"
	require 'gamestates/maingame'

	currentFPS = love.timer.getFPS()
	lowestFPS = 30
	highestFPS = 30
end

function gotoGameState(st)
	currentState = st
	stateTimeStamp = love.timer.getTime()
end

function initiateTweenValues()
 	tweenEngine:newKeyAndValue("scale", 1) -- value used to zoom in and out the whole game
end

function love.keypressed(key)
	if key == "escape" then -- this is global to all states
		print("Lowest FPS: " .. lowestFPS)
		print("Highest FPS: " .. highestFPS)
		love.event.quit()
--	elseif key == "z" then -- USE D FOR DEBUGGING BUTTONS
--		generateItemPack()
	else
		if currentSubState == "none" then
			gameStates[currentState].keypressed(key)
		else -- if in substate, it overrides key input from main gamestate
			gameStates[currentSubState].keypressed(key)
		end
	end
end

function love.mousepressed(x, y, button)
	if currentSubState == "none" then
		gameStates[currentState].mousepressed(x, y, button)
	else -- if in substate, it overrides key input from main gamestate
		gameStates[currentSubState].mousepressed(x, y, button)
	end
end

function love.mousereleased(x, y, button)
	if currentSubState == "none" then
		gameStates[currentState].mousereleased(x, y, button)
	else -- if in substate, it overrides key input from main gamestate
		gameStates[currentSubState].mousereleased(x, y, button)
	end
end

function love.draw()
		gameStates[currentState].draw()
		if not(currentSubState == "none") then -- if in substate, draw both main gamestate and substate
			gameStates[currentSubState].draw()
		end
end

function love.update(dt)
	-- track FPS
	currentFPS = love.timer.getFPS()
	if currentFPS < lowestFPS then lowestFPS = currentFPS end
	if currentFPS > highestFPS then highestFPS = currentFPS end

	timeInState = love.timer.getTime() - stateTimeStamp

	for i=1,timeScale do -- call update as many times as timeScale
		tweenEngine:update(dt)
		gameStates[currentState].update(dt)
		if not(currentSubState == "none") then -- if in substate, update both main gamestate and substate
			gameStates[currentSubState].update(dt)
		end
	end
end
