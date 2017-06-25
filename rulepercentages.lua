-- boid genes are percentages of the rule range
-- this function returns the actual value on the range based on percentage
function getRuleMultiplier(range, percentage, printMe)
  local min = range.lo
  local max = range.hi

  rangeLength = max - min
  step = rangeLength / 100

  if printMe then
    print("percentage " .. percentage)
    print("returning multiplier " .. percentage*step + min)
  end
  return percentage*step + min
end

-- translate the normal value to a percentage to be stored to boid gene value
function getNormalValueAsPercentage(range, printMe)
  local min = range.lo
  local max = range.hi
  rangeLength = max - min
  step = rangeLength / 100

  if printMe then
    print("min " .. min)
    print("max " .. max)
    print("rangeLength " .. rangeLength)
    print("step " .. step)
    print("normal " .. range.no)
    print("gonna return " .. (range.no-min) / step)
  end
  return (range.no-min) / step
end
