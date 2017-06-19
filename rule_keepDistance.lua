function rule_keepDistance(boid, myIndex)
  local returnVector = {x=0, y=0}

  -- for now let's count all boids including self (later should exclude self)

  for i, o in ipairs(boids) do
    if i ~= myIndex then
      local xdist = o.x - boid.x
      local ydist = o.y - boid.y
      local distanceFromSelf = math.sqrt(xdist*xdist + ydist*ydist)
      -- if closer than 100 then push away
      if distanceFromSelf < 300 then
        returnVector.x = returnVector.x - (o.x - boid.x)
        returnVector.y = returnVector.y - (o.y - boid.y)
      end
    end
  end


  return returnVector
end
