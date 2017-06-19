Boid = {}

require "rule_random"
require "rule_towardsFlockCenter"
require "rule_keepDistance"
require "rule_align"
require "rule_avertMouse"

function Boid:new(params)
  o = {}
  o.angle = 0 -- direction as radians (2*pi is 360 degrees), zero is towards right
  o.x = params.x
  o.y = params.y
  o.speed = 100
  o.xspeed = math.cos(o.angle)*o.speed
  o.yspeed = math.sin(o.angle)*o.speed
  o.sprite = love.graphics.newImage("graphics/boid1.png")

  o.isSelected = false

  o.gene_rule_random = 0
  o.gene_rule_towardsFlockCenter = 0.6
  o.gene_rule_keepDistance = 10
  o.gene_rule_align = 1
  o.gene_rule_avertMouse = 10

  setmetatable(o, self)
  self.__index = self
  return o
end

function Boid:update(dt, myIndex)
  dt = dt * timeScale

  -- insert steering here:
  -- go through all Rules and call them with self as parameter
  -- get back a speed speedVector and sum it cumulatively
  -- angle needs then to be calculated from the sum vector
  local speedVector = {x=0, y=0}

  speedVector = rule_random(self)
  self.xspeed = self.xspeed + speedVector.x * self.gene_rule_random * dt
  self.yspeed = self.yspeed + speedVector.y * self.gene_rule_random * dt

  speedVector = rule_towardsFlockCenter(self, myIndex)
  self.xspeed = self.xspeed + speedVector.x * self.gene_rule_towardsFlockCenter * dt
  self.yspeed = self.yspeed + speedVector.y * self.gene_rule_towardsFlockCenter * dt

  speedVector = rule_keepDistance(self, myIndex)
  self.xspeed = self.xspeed + speedVector.x * self.gene_rule_keepDistance * dt
  self.yspeed = self.yspeed + speedVector.y * self.gene_rule_keepDistance * dt

  speedVector = rule_align(self, myIndex)
  self.xspeed = self.xspeed + speedVector.x * self.gene_rule_align * dt
  self.yspeed = self.yspeed + speedVector.y * self.gene_rule_align * dt

  speedVector = rule_avertMouse(self, myIndex)
  self.xspeed = self.xspeed + speedVector.x * self.gene_rule_avertMouse * dt
  self.yspeed = self.yspeed + speedVector.y * self.gene_rule_avertMouse * dt

  -- limiting speed to a max without affecting direction - it's like FRICTION
  local velocity = math.sqrt(self.xspeed*self.xspeed + self.yspeed*self.yspeed)
  if velocity > FrictionLimitVelocity then
    local unitVector = {x=self.xspeed/velocity, y=self.yspeed/velocity}
    local speeding = velocity - FrictionLimitVelocity -- how much over
    local frictionVector = {x = -1*unitVector.x*speeding, y = -1*unitVector.y*speeding}
    self.xspeed = self.xspeed + frictionVector.x * FrictionMultiplier * dt
    self.yspeed = self.yspeed + frictionVector.y * FrictionMultiplier * dt
  end

  self.x = self.x + self.xspeed * dt
  self.y = self.y + self.yspeed * dt
  self.angle = math.atan2(self.yspeed, self.xspeed)

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
