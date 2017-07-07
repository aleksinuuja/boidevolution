Tween = {}

function Tween:new(params)
  o = {}
  o.Keys = {}
 	o.Values = {}
 	o.Tweens = {}

  setmetatable(o, self)
  self.__index = self
  return o
end

function Tween:debug()
  local i
  print("All key and value pairs in tweening currently: ")
  for i = 1, #self.Keys do
    print("Key: " .. self.Keys[i] .. ", Value: " .. self.Values[i])
  end

  print("All tweens currently, show key for each: ")
  for i = 1, #self.Tweens do
    print("Key: " .. self.Tweens[i].key)
  end
end

function Tween:update(dt)
  -- for each Tween, find the key and update the value
  local i, o, i2
	for i, o in ipairs(self.Tweens) do
    o.timer = o.timer + dt
		for i2 = 1, #self.Keys do
			if self.Keys[i2] == o.key then
        self.Values[i2] = o.tweenFunction(o.timer, o.start, o.target-o.start, o.duration)
				if o.timer >= o.duration then -- duration has passed
          self.Values[i2] = o.target -- set to exactly target value at the end
					table.remove(self.Tweens, i)
          break
				end
			end
		end
	end
end

-- speed is a multiplier, suggest using values 1 to 200 (slow to fast tween)
function Tween:createTween(keyName, startValue, targetValue, duration, func)
  if startValue == "none" then startValue = 1 end

  -- check if the value is already being tweened - multiple simultaneous tweens for same key are not allowed!
  local alreadyTweening = false
  for i = 1, #self.Tweens do
    if self.Tweens[i].key == keyName then
--      print("ALREADY TWEENING! keyName = " .. keyName)
      alreadyTweening = true
    end
  end

  if not alreadyTweening then
    table.insert(self.Tweens, {
      timer = 0,
      key = keyName,
      start = startValue,
      target = targetValue,
      duration = duration,
      tweenFunction = func})
  end
end

function Tween:newKeyAndValue(keyName, initValue)
  for i = 1, #self.Keys do
    if self.Keys[i] == keyName then return 0 end -- if key already exists break and return 0
  end
  table.insert(self.Keys, keyName)
  table.insert(self.Values, initValue)
end


function Tween:returnValue(keyName)
  for i = 1, #self.Keys do
    if self.Keys[i] == keyName then return self.Values[i] end
  end
  return "none"
end

function Tween:setValue(keyName, newValue)
  for i = 1, #self.Keys do
    if self.Keys[i] == keyName then self.Values[i] = newValue end
  end
end

-- tween functions from http://gizma.com/easing/
-- t current time
-- b start value
-- c change in value (target value - b)
-- duration
-- every tween has a timer that goes from 0 to d and is given to tween function as t
function linearTween(t, b, c, d)
	return c*t/d + b
end

function easeOutQuint(t, b, c, d)
	t = t/d
	t = t-1
	return c*(t*t*t*t*t + 1) + b
end

function easeInOutCubic(t, b, c, d)
	t = t / (d/2)
	if (t < 1) then return c/2*t*t*t + b end
	t = t-2
	return c/2*(t*t*t + 2) + b
end


function tv(key) -- short syntax for fetching tweenable value
	return tonumber(tweenEngine:returnValue(key))
end
