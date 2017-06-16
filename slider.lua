Slider = {}

function Slider:new(params)
  o = {}
  o.initiated = false
  o.x = params.x
  o.y = params.y
  o.width = params.width
  o.valuesUpTo = params.valuesUpTo
  o.leftLimit = o.x
  o.rightLimit = o.x + o.width
  o.value = 1

  o.rect = {
    x = o.x,
    y = o.y,
    width = 40,
    height = 40
  }
  o.dragging = { active = false, diffX = 0, diffY = 0 }

  setmetatable(o, self)
  self.__index = self
  return o
end

function Slider:draw()
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("fill", self.leftLimit, self.y+18, self.width+40, 4)

  love.graphics.setColor(255, 255, 255)
  love.graphics.rectangle("fill", self.rect.x, self.rect.y, self.rect.width, self.rect.height)
end


function Slider:update(dt)
  if self.dragging.active then
    self.rect.x = love.mouse.getX() - self.dragging.diffX
    if self.rect.x < self.leftLimit then self.rect.x = self.leftLimit end
    if self.rect.x > self.rightLimit then self.rect.x = self.rightLimit end

--    self.value = round((self.rect.x-self.x)/(self.valuesUpTo+1),0) + 1

    -- ok we need to figure out what value this slider gives on a range from 1 to self.valuesUpTo
    -- we know the rect's x coordinate
    -- we can calculate the distance of that to the leftLimit
    -- then we can find out how many notches that is from 1
    -- one notch is the width of the slider divided by valuesUpTo
    local notch = self.width/(self.valuesUpTo-1)
    self.value = round((self.rect.x - self.leftLimit) / notch) + 1



  end
end
