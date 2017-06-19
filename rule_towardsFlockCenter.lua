function rule_towardsFlockCenter(boid, myIndex)
  local returnVector = {x=0, y=0}

  -- find the "center of mass" that is the average of x coordinates and y coordinates
  for i, o in ipairs(boids) do
    if i ~= myIndex then
      returnVector.x = returnVector.x + o.x
      returnVector.y = returnVector.y + o.y
    end
  end
  returnVector.x = returnVector.x / #boids
  returnVector.y = returnVector.y / #boids

  -- compare own location to center to find vector towards center
  returnVector.x = returnVector.x - boid.x
  returnVector.y = returnVector.y - boid.y

  return returnVector
end
