function rule_avertMouse(boid, myIndex)
  local returnVector = {x=0, y=0}

  -- distance to mouse
  local xdist = love.mouse.getX()/tv("scale") - boid.x
  local ydist = love.mouse.getY()/tv("scale") - boid.y
  local distanceFromMouse = math.sqrt(xdist*xdist + ydist*ydist)

  if distanceFromMouse < 2500 then
    -- compare own location to mouse to find vector towards center
    returnVector.x = - (love.mouse.getX()/tv("scale") - boid.x)
    returnVector.y = - (love.mouse.getY()/tv("scale") - boid.y)
  end

  return returnVector
end
