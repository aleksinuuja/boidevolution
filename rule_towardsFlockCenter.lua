function rule_towardsFlockCenter(boid)
  local returnVector = {x=0, y=0}

  -- for now let's count all boids including self (later should exclude self)

  -- find the "center of mass" that is the average of x coordinates and y coordinates
  for i, o in ipairs(boids) do
    returnVector.x = returnVector.x + o.x
    returnVector.y = returnVector.y + o.y
  end
  returnVector.x = returnVector.x / #boids
  returnVector.y = returnVector.y / #boids

  -- compare own location to center to find vector towards center
  returnVector.x = returnVector.x - boid.x
  returnVector.y = returnVector.y - boid.y

--[[
  -- to make this a unit vector we need to divide by length
  local vectorLength = math.sqrt(returnVector.x*returnVector.x + returnVector.y*returnVector.y)
  returnVector.x = returnVector.x / vectorLength
  returnVector.y = returnVector.y / vectorLength
]]--

  return returnVector
end
