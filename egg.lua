Egg = {}


function Egg:new(params)
  o = {}
  o.x = params.x
  o.y = params.y
  o.race = params.race
  o.countDown = 100
  o.lastStamp = love.timer.getTime()
  o.tickDuration = 0.5 -- countDown ticker

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

  setmetatable(o, self)
  self.__index = self
  return o
end

function Egg:update(dt, myIndex)
  -- aging and death
  local timeElapsed = love.timer.getTime() - self.lastStamp
  if timeElapsed > (self.tickDuration/timeScale) then
    self.lastStamp = love.timer.getTime()
    -- call tick function now
    self.countDown = self.countDown - 1

    -- when close to hatching, the egg starts to shake
    if self.countDown < 20 then
      self.x = self.x + math.random()*4-2
      self.y = self.y + math.random()*4-2
    end

    if self.countDown < 1 then
      self.removeMe = true

      local race = self.race
      table.insert(boids, Boid:new({
        race = race,
        gene_rule_random = self.gene_rule_random,
        gene_rule_towardsFlockCenter = self.gene_rule_towardsFlockCenter,
        gene_rule_keepDistance = self.gene_rule_keepDistance,
        gene_rule_align = self.gene_rule_align,
        gene_rule_avertEnemies = self.gene_rule_avertEnemies,
        gene_rule_keepDistance_distance = self.gene_rule_keepDistance_distance,
        gene_rule_avertEnemies_distance = self.gene_rule_avertEnemies_distance,
        gene_rule_searchFood = self.gene_rule_searchFood,
        gene_rule_searchFood_distance = self.gene_rule_searchFood_distance,
        gene_rule_searchEggs = self.gene_rule_searchEggs,
        gene_rule_searchEggs_distance = self.gene_rule_searchEggs_distance,
        x = self.x,
        y = self.y}))
    end
  end
end

function Egg:draw()
  if self.race == 1 then
    love.graphics.setColor(200, 50, 150)
  elseif self.race == 2 then
    love.graphics.setColor(200, 200, 0)
  elseif self.race == 3 then
    love.graphics.setColor(50, 50, 250)
  else
    love.graphics.setColor(0, 200, 0)
  end
  love.graphics.rectangle("fill", self.x, self.y, 50, 50)
end

function Egg:drawShadow()
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("fill", self.x+150, self.y+150, 50, 50)
end
