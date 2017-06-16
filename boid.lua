Boid = {}

function Boid:new(params)
  o = {}
  o.angle = 0 -- direction as radians (2*pi is 360 degrees), zero is towards right
  o.x = params.x
  o.y = params.y
  o.xspeed = 0
  o.yspeed = 0
  o.speed = 1000
  o.sprite = love.graphics.newImage("graphics/boid1.png")

  o.isSelected = false

  setmetatable(o, self)
  self.__index = self
  return o
end

function Boid:update(dt)
  dt = dt * timeScale

  -- insert steering here
  self.angle = self.angle + ((math.random(200)-100)/10) * dt


  self.xspeed = math.cos(self.angle) * self.speed
  self.yspeed = math.sin(self.angle) * self.speed
  self.x = self.x + self.xspeed * dt
  self.y = self.y + self.yspeed * dt

  -- universe boundaries - WRAP AROUND
  if self.x < -80 then
    self.x = self.x+(universe.width+80)
  end
  if self.x > universe.width+80 then
    self.x = self.x-(universe.width+80)
  end
  if self.y < -80  then
    self.y = self.y+(universe.height+80)
  end
  if self.y > universe.height+80 then
    self.y = self.y-(universe.height+80)
  end
end

function Boid:draw()
  -- draw a shadow for fun (first so it's on bottom)
  love.graphics.setColor(0, 0, 0)
  love.graphics.draw(self.sprite, self.x+150, self.y+150, self.angle-math.pi/2, 1, 1, 70, 93)

  -- if boid is selected draw a circle around it
  if self.isSelected then
    love.graphics.setColor(0, 200, 0)
    love.graphics.setLineWidth(2/tv("scale"))
    love.graphics.circle("line", self.x, self.y, 160)
  end

  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(self.sprite, self.x, self.y, self.angle-math.pi/2, 1, 1, self.sprite:getWidth()/2, self.sprite:getHeight()/2)

end
