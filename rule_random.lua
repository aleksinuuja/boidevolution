function rule_random(boid)
  local returnVector = {x=0, y=0}

  local angle = math.random() * math.pi*2

  returnVector.x = math.cos(angle)
  returnVector.y = math.sin(angle)

  return returnVector
end
