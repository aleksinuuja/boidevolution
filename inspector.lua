Inspector = {}

function Inspector:new(params)
  o = {}
  o.x = params.x
  o.y = params.y
  o.width = 200
  o.height = 500

  -- close button is a 20 by 20 square with 5 pixel intendation from top right corner
  o.close = {}
  o.close.x = o.x + (o.width-(20+5))
  o.close.y = o.y + 5
  o.close.width = 20
  o.close.height = 20

  -- next button is a 40 by 40 square with 5 pixel intendation from top bottom corner
  o.next = {}
  o.next.x = o.x + (o.width-(40+5))
  o.next.y = o.y + (o.height-(40+5))
  o.next.width = 40
  o.next.height = 40

  -- prev button is a 40 by 40 square with 5 pixel intendation from top bottom corner
  o.prev = {}
  o.prev.x = o.x + 5
  o.prev.y = o.y + (o.height-(40+5))
  o.prev.width = 40
  o.prev.height = 40

  local font = love.graphics.newFont("graphics/Krungthep.ttf", self.textsize)
  o.text = love.graphics.newText(font, "")

  o.isVisible = false
  o.dragging = { active = false, diffX = 0, diffY = 0 }

  setmetatable(o, self)
  self.__index = self
  return o
end

function Inspector:update(dt)
  if self.dragging.active then
    self.x = love.mouse.getX() - self.dragging.diffX
    self.y = love.mouse.getY() - self.dragging.diffY
    self.close.x = self.x + (self.width-(20+5))
    self.close.y = self.y + 5
    self.next.x = self.x + (self.width-(40+5))
    self.next.y = self.y + (self.height-(40+5))
    self.prev.x = self.x + 5
    self.prev.y = self.y + (self.height-(40+5))
  end
end

function Inspector:draw()
  if self.isVisible then
    -- frame
    love.graphics.setColor(0, 200, 0)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height, 5, 5)

    -- black box
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 5, 5)

    -- dragging bar at top
    love.graphics.setColor(50, 50, 50)
    love.graphics.rectangle("fill", self.x, self.y, self.width, 30, 5, 5)

    -- close button
    love.graphics.setColor(50, 200, 50)
    love.graphics.rectangle("fill", self.close.x, self.close.y, self.close.width, self.close.height, 5, 5)

    -- next button
    love.graphics.setColor(0, 200, 0)
    love.graphics.rectangle("fill", self.next.x, self.next.y, self.next.width, self.next.height, 5, 5)

    -- prev button
    love.graphics.setColor(0, 200, 0)
    love.graphics.rectangle("fill", self.prev.x, self.prev.y, self.prev.width, self.prev.height, 5, 5)

    -- show selected boid
    if selectedBoid > 0 then
      local race = boids[selectedBoid].race
      if race == 1 then
        love.graphics.setColor(200, 50, 150)
      elseif race == 2 then
        love.graphics.setColor(200, 200, 0)
      elseif race == 3 then
        love.graphics.setColor(50, 50, 250)
      else
        love.graphics.setColor(0, 200, 0)
      end
      love.graphics.draw(boids[selectedBoid].sprite, self.x+self.width/2, self.y+64, boids[selectedBoid].angle-math.pi/2, 0.25, 0.25, boids[selectedBoid].sprite:getWidth()/2, boids[selectedBoid].sprite:getHeight()/2)

      -- show text: boid name and stats
      self.text:clear()
      local stringToShow = "Selected Boid > " .. selectedBoid .. "\n"
      stringToShow = stringToShow .. "\n\nAge: " .. boids[selectedBoid].age .. " ticks"
      stringToShow = stringToShow .. "\n\nEnergy: " .. boids[selectedBoid].energy

      -- TODO: these should show CHANGE against normal values
      stringToShow = stringToShow .. "\n\nrandom: " ..round(boids[selectedBoid].gene_rule_random, 2) .. "   - diff: " .. round(boids[selectedBoid].gene_rule_random - getNormalValueAsPercentage(gene_rule_random_range, false), 2)
      stringToShow = stringToShow .. "\ntowardsCent: " ..round(boids[selectedBoid].gene_rule_towardsFlockCenter, 2).. "   - diff: " .. round(boids[selectedBoid].gene_rule_towardsFlockCenter - getNormalValueAsPercentage(gene_rule_towardsFlockCenter_range, false), 2)
      stringToShow = stringToShow .. "\nalign: " ..round(boids[selectedBoid].gene_rule_align, 2).. "   - diff: " .. round(boids[selectedBoid].gene_rule_align - getNormalValueAsPercentage(gene_rule_align_range, false), 2)
      stringToShow = stringToShow .. "\nkeepDist: " ..round(boids[selectedBoid].gene_rule_keepDistance, 2).. "   - diff: " .. round(boids[selectedBoid].gene_rule_keepDistance - getNormalValueAsPercentage(gene_rule_keepDistance_range, false), 2)
      stringToShow = stringToShow .. "\nkeepDist_d: " ..round(boids[selectedBoid].gene_rule_keepDistance_distance, 2).. "   - diff: " .. round(boids[selectedBoid].gene_rule_keepDistance_distance - getNormalValueAsPercentage(gene_rule_keepDistance_distance_range, false), 2)
      stringToShow = stringToShow .. "\navertE: " ..round(boids[selectedBoid].gene_rule_avertEnemies, 2).. "   - diff: " .. round(boids[selectedBoid].gene_rule_avertEnemies - getNormalValueAsPercentage(gene_rule_avertEnemies_range, false), 2)
      stringToShow = stringToShow .. "\navertE_d: " ..round(boids[selectedBoid].gene_rule_avertEnemies_distance, 2).. "   - diff: " .. round(boids[selectedBoid].gene_rule_avertEnemies_distance - getNormalValueAsPercentage(gene_rule_avertEnemies_distance_range, false), 2)
      stringToShow = stringToShow .. "\nsearchF: " ..round(boids[selectedBoid].gene_rule_searchFood, 2).. "   - diff: " .. round(boids[selectedBoid].gene_rule_searchFood - getNormalValueAsPercentage(gene_rule_searchFood_range, false), 2)
      stringToShow = stringToShow .. "\nsearchF_d: " ..round(boids[selectedBoid].gene_rule_searchFood_distance, 2).. "   - diff: " .. round(boids[selectedBoid].gene_rule_searchFood_distance - getNormalValueAsPercentage(gene_rule_searchFood_distance_range, false), 2)
      stringToShow = stringToShow .. "\nsearchE: " ..round(boids[selectedBoid].gene_rule_searchEggs, 2).. "   - diff: " .. round(boids[selectedBoid].gene_rule_searchEggs - getNormalValueAsPercentage(gene_rule_searchEggs_range, false), 2)
      stringToShow = stringToShow .. "\nsearchE_d: " ..round(boids[selectedBoid].gene_rule_searchEggs_distance, 2).. "   - diff: " .. round(boids[selectedBoid].gene_rule_searchEggs_distance - getNormalValueAsPercentage(gene_rule_searchEggs_distance_range, false), 2)


      local foo = self.text:set(stringToShow)
      love.graphics.setColor(0, 200, 0)
      love.graphics.draw(self.text, self.x+5, self.y + 100)
    end

  end
end
