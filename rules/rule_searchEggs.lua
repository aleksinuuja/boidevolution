function rule_searchEggs(boid, myIndex, dist)
  local returnVector = {x=0, y=0}
  local closestDistance = 1000000
  local closestEggIndex = 0

  -- find closest egg
  for i, o in ipairs(eggs) do
    if o.race ~= boid.race then
      local xdist = o.x - boid.x
      local ydist = o.y - boid.y
      local distanceFromSelf = math.sqrt(xdist*xdist + ydist*ydist)
      -- if closer than dist then consider
      if distanceFromSelf < dist then
        -- if closer than the previous one that was closest then update
        if distanceFromSelf < closestDistance then
          closestDistance = distanceFromSelf
          closestEggIndex = i
        end
      end
    end
  end

  if closestEggIndex > 0 then
    returnVector.x = returnVector.x + (eggs[closestEggIndex].x - boid.x)
    returnVector.y = returnVector.y + (eggs[closestEggIndex].y - boid.y)
  end

  return returnVector
end
