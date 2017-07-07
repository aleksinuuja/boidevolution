Boid = {}

require "rules/rule_random"
require "rules/rule_towardsFlockCenter"
require "rules/rule_keepDistance"
require "rules/rule_align"
require "rules/rule_avertMouse"
require "rules/rule_avertEnemies"
require "rules/rule_searchFood"
require "rules/rule_searchEggs"

function Boid:new(params)
  o = {}
  o.angle = 0 -- direction as radians (2*pi is 360 degrees), zero is towards right
  o.x = params.x
  o.y = params.y
  o.speed = 0
  o.xspeed = math.cos(o.angle)*o.speed
  o.yspeed = math.sin(o.angle)*o.speed
  o.sprite = love.graphics.newImage("graphics/boid1.png")
  o.race = params.race

  o.birthStamp = love.timer.getTime()
  o.age = 0
  o.energy = 100
  o.lastStamp = love.timer.getTime()
  o.tickDuration = 0.5 -- aging ticker


  o.isSelected = false
  o.removeMe = false

  o.gene_rule_random = params.gene_rule_random
  o.gene_rule_towardsFlockCenter = params.gene_rule_towardsFlockCenter
  o.gene_rule_keepDistance = params.gene_rule_keepDistance
  o.gene_rule_align = params.gene_rule_align
  o.gene_rule_avertEnemies = params.gene_rule_avertEnemies
  o.gene_rule_keepDistance_distance = params.gene_rule_keepDistance_distance
  o.gene_rule_avertEnemies_distance = params.gene_rule_avertEnemies_distance
  o.gene_rule_searchFood = params.gene_rule_searchFood
  o.gene_rule_searchFood_distance = params.gene_rule_searchFood_distance
  o.gene_rule_searchEggs = params.gene_rule_searchEggs
  o.gene_rule_searchEggs_distance = params.gene_rule_searchEggs_distance

  -- o.gene_rule_random = 0
  -- o.gene_rule_towardsFlockCenter = 0
  -- o.gene_rule_keepDistance = 0
  -- o.gene_rule_align = 0 -- if too high boids fly to hell (wait max speed friction is not working)
  -- o.gene_rule_avertEnemies = 0
  -- o.gene_rule_keepDistance_distance = 100
  -- o.gene_rule_avertEnemies_distance = 100
  -- o.gene_rule_searchFood = 1
  -- o.gene_rule_searchFood_distance = 1000
  -- o.gene_rule_searchEggs = 2
  -- o.gene_rule_searchEggs_distance = 10000

  o.gene_rule_avertMouse = 0

  setmetatable(o, self)
  self.__index = self
  return o
end

function Boid:update(dt, myIndex)
  -- aging and death
  local timeElapsed = love.timer.getTime() - self.lastStamp
  if timeElapsed > (self.tickDuration/timeScale) then
    self.lastStamp = love.timer.getTime()
    -- call tick function now
    self.age = self.age + 1
    self.energy = self.energy - 1
    if self.energy < 1 then self.removeMe = true end
  end

  -- laying eggs, takes 100 energy
  local diceRoll = math.random(1000)
  if diceRoll == 1 and self.energy > 150 then
    createEgg(self, self.x, self.y, self.race)
    self.energy = self.energy - 100
  end

  -- steering:
  local speedVector = {x=0, y=0}

  speedVector = rule_random(self)
  local m = getRuleMultiplier(gene_rule_random_range, self.gene_rule_random, false)
  self.xspeed = self.xspeed + speedVector.x * m * dt
  self.yspeed = self.yspeed + speedVector.y * m * dt

  speedVector = rule_towardsFlockCenter(self, myIndex)
  m = getRuleMultiplier(gene_rule_towardsFlockCenter_range, self.gene_rule_towardsFlockCenter, false)
  self.xspeed = self.xspeed + speedVector.x * m * dt
  self.yspeed = self.yspeed + speedVector.y * m * dt

  local distance = getRuleMultiplier(gene_rule_keepDistance_distance_range, self.gene_rule_keepDistance_distance, false)
  speedVector = rule_keepDistance(self, myIndex, distance)
  m = getRuleMultiplier(gene_rule_keepDistance_range, self.gene_rule_keepDistance, false)
  self.xspeed = self.xspeed + speedVector.x * m * dt
  self.yspeed = self.yspeed + speedVector.y * m * dt

  speedVector = rule_align(self, myIndex)
  m = getRuleMultiplier(gene_rule_align_range, self.gene_rule_align, false)
  self.xspeed = self.xspeed + speedVector.x * m * dt
  self.yspeed = self.yspeed + speedVector.y * m * dt

--[[
  speedVector = rule_avertMouse(self, myIndex)
  m = getRuleMultiplier(gene_rule_avertMouse_range, self.gene_rule_avertMouse)
  print(5)
  self.xspeed = self.xspeed + speedVector.x * m * dt
  self.yspeed = self.yspeed + speedVector.y * m * dt
  ]]--

  distance = getRuleMultiplier(gene_rule_avertEnemies_distance_range, self.gene_rule_avertEnemies_distance, false)
  speedVector = rule_avertEnemies(self, myIndex, distance)
  m = getRuleMultiplier(gene_rule_avertEnemies_range, self.gene_rule_avertEnemies, false)
  self.xspeed = self.xspeed + speedVector.x * m * dt
  self.yspeed = self.yspeed + speedVector.y * m * dt

  distance = getRuleMultiplier(gene_rule_searchFood_distance_range, self.gene_rule_searchFood_distance, false)
  speedVector = rule_searchFood(self, myIndex, distance)
  m = getRuleMultiplier(gene_rule_searchFood_range, self.gene_rule_searchFood, false)
  self.xspeed = self.xspeed + speedVector.x * m * dt
  self.yspeed = self.yspeed + speedVector.y * m * dt

  distance = getRuleMultiplier(gene_rule_searchEggs_distance_range, self.gene_rule_searchEggs_distance, false)
  speedVector = rule_searchEggs(self, myIndex, distance)
  m = getRuleMultiplier(gene_rule_searchEggs_range, self.gene_rule_searchEggs, false)
  self.xspeed = self.xspeed + speedVector.x * m * dt
  self.yspeed = self.yspeed + speedVector.y * m * dt


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
  -- if boid is selected draw a circle around it
  if self.isSelected then
    love.graphics.setColor(0, 200, 0)
    love.graphics.setLineWidth(2/tv("scale"))
    love.graphics.circle("line", self.x, self.y, 160)
  end

  if self.race == 1 then
    love.graphics.setColor(200, 50, 150)
  elseif self.race == 2 then
    love.graphics.setColor(200, 200, 0)
  elseif self.race == 3 then
    love.graphics.setColor(50, 50, 250)
  else
    love.graphics.setColor(0, 200, 0)
  end
  love.graphics.draw(self.sprite, self.x, self.y, self.angle-math.pi/2, 1, 1, self.sprite:getWidth()/2, self.sprite:getHeight()/2)

end
function Boid:drawShadow()
  -- draw a shadow for fun (first so it's on bottom)
  love.graphics.setColor(0, 0, 0)
  love.graphics.draw(self.sprite, self.x+150, self.y+150, self.angle-math.pi/2, 1, 1, 70, 93)
end
