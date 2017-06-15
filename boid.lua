Boid = {}

function Boid:new(params)
  o = {}
  o.angle = 0 -- direction as radians (2*pi is 360 degrees), zero is towards right
  o.x = params.x
  o.y = params.y
  o.xspeed = 0
  o.yspeed = 0
  o.sprite = love.graphics.newImage("graphics/boid1.png")

  setmetatable(o, self)
  self.__index = self
  return o
end

function Boid:update(dt)
	self.x = self.x + self.xspeed * dt
  self.y = self.y + self.yspeed * dt
  self.angle = math.atan2(self.yspeed, self.xspeed)

  -- universe boundaries
  if self.x < 40 then self.xspeed = 1  end
  if self.x > universe.width-40 then self.xspeed = -1  end
  if self.y < 40  then self.yspeed = 1 end
  if self.y > universe.height-40 then self.yspeed = -1 end
end

function Boid:draw()
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(self.sprite, self.x, self.y, self.angle-math.pi/2, 1, 1, 70, 93)
end
