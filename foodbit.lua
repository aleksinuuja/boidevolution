FoodBit = {}


function FoodBit:new(params)
  o = {}
  o.x = params.x
  o.y = params.y

  setmetatable(o, self)
  self.__index = self
  return o
end

function FoodBit:update(dt, myIndex)
-- we just sit here
end

function FoodBit:draw()
  love.graphics.setColor(150, 150, 150)
  love.graphics.rectangle("fill", self.x, self.y, 50, 50)
end

function FoodBit:drawShadow()
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("fill", self.x+150, self.y+150, 50, 50)
end
