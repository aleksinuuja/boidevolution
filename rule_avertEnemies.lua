function rule_avertEnemies(boid, myIndex, dist)
  local returnVector = {x=0, y=0}

  for i, o in ipairs(boids) do
    if i ~= myIndex and boid.race ~= o.race then
      local xdist = o.x - boid.x
      local ydist = o.y - boid.y
      local distanceFromSelf = math.sqrt(xdist*xdist + ydist*ydist)
      -- if closer than 100 then push away
      if distanceFromSelf < dist then
        returnVector.x = returnVector.x - (o.x - boid.x)
        returnVector.y = returnVector.y - (o.y - boid.y)
      end
    end
  end
  return returnVector
end
