function rule_align(boid, myIndex)
  local returnVector = {x=0, y=0}
  local count = 1

  -- find the average speed of other mates
  for i, o in ipairs(boids) do
    if i ~= myIndex and boid.race == o.race then
      count = count + 1
      returnVector.x = returnVector.x + o.xspeed
      returnVector.y = returnVector.y + o.yspeed
    end
  end
  returnVector.x = returnVector.x / count
  returnVector.y = returnVector.y / count

  return returnVector
end
