Egg = {}


function Egg:new(params)
  o = {}
  o.x = params.x
  o.y = params.y
  o.race = params.race
  o.countDown = 100
  o.lastStamp = love.timer.getTime()
  o.tickDuration = 0.5 -- countDown ticker

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
        gene_rule_random = gene_rule_random_range.no,
        gene_rule_towardsFlockCenter = gene_rule_towardsFlockCenter_range.no,
        gene_rule_keepDistance = gene_rule_keepDistance_range.no,
        gene_rule_align = gene_rule_align_range.no,
        gene_rule_avertEnemies = gene_rule_avertEnemies_range.no,
        gene_rule_keepDistance_distance = gene_rule_keepDistance_distance_range.no,
        gene_rule_avertEnemies_distance = gene_rule_avertEnemies_distance_range.no,
        gene_rule_searchFood = gene_rule_searchFood_range.no,
        gene_rule_searchFood_distance = gene_rule_searchFood_distance_range.no,
        gene_rule_searchEggs = gene_rule_searchEggs_range.no,
        gene_rule_searchEggs_distance = gene_rule_searchEggs_distance_range.no,
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
