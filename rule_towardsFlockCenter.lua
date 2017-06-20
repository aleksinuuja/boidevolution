function rule_towardsFlockCenter(boid, myIndex)
  local count = 0
  local returnVector = {x=0, y=0}

  -- find the "center of mass" that is the average of x coordinates and y coordinates
  for i, o in ipairs(boids) do
    if i ~= myIndex and boid.race == o.race then
      count = count + 1
      returnVector.x = returnVector.x + o.x
      returnVector.y = returnVector.y + o.y
    end
  end
  if count > 0 then
    returnVector.x = returnVector.x / count
    returnVector.y = returnVector.y / count
  end

  -- compare own location to center to find vector towards center
  returnVector.x = returnVector.x - boid.x
  returnVector.y = returnVector.y - boid.y

  return returnVector
end
