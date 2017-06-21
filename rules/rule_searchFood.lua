function rule_searchFood(boid, myIndex, dist)
  local returnVector = {x=0, y=0}
  local closestDistance = 1000000
  local closestFoodBitIndex = 0

  -- find closest foobit
  for i, o in ipairs(foodBits) do
    local xdist = o.x - boid.x
    local ydist = o.y - boid.y
    local distanceFromSelf = math.sqrt(xdist*xdist + ydist*ydist)
    -- if closer than dist then consider
    if distanceFromSelf < dist then
      -- if closer than the previous one that was closest then update
      if distanceFromSelf < closestDistance then
        closestDistance = distanceFromSelf
        closestFoodBitIndex = i
      end
    end
  end

  if closestFoodBitIndex > 0 then
    returnVector.x = returnVector.x + (foodBits[closestFoodBitIndex].x - boid.x)
    returnVector.y = returnVector.y + (foodBits[closestFoodBitIndex].y - boid.y)
  end

  return returnVector
end
