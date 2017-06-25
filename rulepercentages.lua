-- boid genes are percentages of the rule range
-- this function returns the actual value on the range based on percentage
function getRuleMultiplier(range, percentage)
  local min = range.lo
  local max = range.hi

  rangeLength = max - min
  step = rangeLength / 100

  return min + percentage*step
end

-- translate the normal value to a percentage to be stored to boid gene value
function getNormalValueAsPercentage(range)
  local min = range.lo
  local max = range.hi
  rangeLength = max - min
  step = rangeLength / 100

  print("min " .. min)
  print("max " .. max)
  print("rangeLength " .. rangeLength)
  print("step " .. step)
  print("normal " .. range.no)
  print("gonna return " .. (min+range.no) / step)
  return (min + range.no) / step
end
