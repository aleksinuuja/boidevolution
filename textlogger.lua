Textlogger = {}

function Textlogger:new(params)
  o = {}
  o.Texts = {}
  o.msgs = {}
  o.msgColours = {}
  o.initiated = false
  o.timeStamp = os.time()
  o.timer = 0
  o.animFlag = false

  o.maxrows = params.maxrows
  o.rowheight = params.rowheight
  o.textsize = params.textsize
  o.updateSpeed = params.updateSpeed -- seconds (how often log scrolls on it's own)
  o.blinkDuration = params.blinkDuration -- milliseconds how quickly new message blinks
  o.maxBlinks = params.maxBlinks

  o.blinkTimeStamp = love.timer.getTime() -- to compare milliseconds
  o.blinkCounter = 0
  o.blinkFlag = false
  o.blinkTimer = 0
  o.blinkPhase = "off"

  o.x = params.x
  o.y = params.y

  setmetatable(o, self)
  self.__index = self
  return o
end

function Textlogger:draw()
  local drawOrNot = false
  local i
  for i = 1, #self.msgs do
    drawOrNot = false
      if not(self.msgs[i] == "") then
        self.Texts[i]:clear()
        local foo = self.Texts[i]:set("> " .. self.msgs[i])

        if i == #self.msgs then -- only last row can blink
          if self.blinkFlag then -- is blinking so draw only if blinkPhase "on"
            if self.blinkPhase == "on" then
              drawOrNot = true
            end
          else -- is not blinking so draw
            drawOrNot = true
          end
        else -- is not last row so always draw
          drawOrNot = true
        end
      end
      -- if just started tween don't draw as the value is not changed yet
      if self.animFlag and tv("logTextY") > 0 then drawOrNot = false end
      if drawOrNot then
        if i == 1 then -- first row fades out
          if self.msgColours[i] == "green" then love.graphics.setColor(0, 255, 0, LOGALPHA)
          elseif self.msgColours[i] == "red" then love.graphics.setColor(255, 0, 150, LOGALPHA) end
          love.graphics.draw(self.Texts[i], self.x, self.y + tv("logTextY") + (i*self.rowheight))
        else
          if self.msgColours[i] == "green" then love.graphics.setColor(0, 255, 0)
          elseif self.msgColours[i] == "red" then love.graphics.setColor(255, 0, 150) end
          love.graphics.draw(self.Texts[i], self.x, self.y + tv("logTextY") + (i*self.rowheight))
        end
      end
  end
end

function Textlogger:update(dt)
  self.timer = os.difftime(os.time(), self.timeStamp)
  self.blinkTimer =  love.timer.getTime() - self.blinkTimeStamp  -- milliseconds

  -- fix: zero out the animFlag in middle of the tween
  local c = tv("logTextY")
  if 10 < c and c < 48 and self.animFlag then self.animFlag = false end

  if not self.initiated then
    self.initiated = true
    self:createTextRows(self.maxrows)
  end

  -- we want an update happening every T seconds where T = self.updateSpeed
  -- then the log scrolls up one row at a time to emptiness
  -- we want tween transitions, so that the lines move up and fade out to nothingness on top
  if self.timer >= self.updateSpeed then
    self.animFlag = true
    self.timeStamp = os.time()

    local i
    for i = 2, #self.msgs do
      self.msgs[i-1] = self.msgs[i]
      self.msgColours[i-1] = self.msgColours[i]
    end

    -- empty new message is added to the bottom row
    self.msgs[#self.msgs] = ""
    self.msgColours[#self.msgs] = ""

    -- scrolling is animated with a tween
    tweenEngine:createTween("logTextY", self.rowheight, 0, 0.5, linearTween)
    tweenEngine:createTween("logAlpha", 255, 0, 0.5, linearTween)
  end

  -- blinking logic
  if self.blinkFlag then
    if self.blinkTimer >= self.blinkDuration then
      self.blinkTimeStamp = love.timer.getTime() -- milliseconds
      if self.blinkPhase == "off" then
        self.blinkPhase = "on"
        self.blinkCounter = self.blinkCounter + 1
      elseif self.blinkPhase == "on" then self.blinkPhase = "off" end
      if self.blinkCounter == self.maxBlinks then self.blinkFlag = false end
    end
  end
end

function Textlogger:createTextRows(amount)
  -- create a table of messages (initally empty strings), one for each row
  -- if rows have params.eters, create a table for each - use same index to refer to row message and params.eter
  -- also, create a table of Text object, used when drawing the text on screen

  local font = love.graphics.newFont("graphics/Krungthep.ttf", self.textsize)
  local emptyText = love.graphics.newText(font, "")

  local i
  for i = 1, amount do
    table.insert(self.msgs, "")
    table.insert(self.msgColours, "")
    table.insert(self.Texts, emptyText)
  end
end

function Textlogger:newMessage(message, colour)
  -- when new message is logged, we scroll previous messages up
  local i
  for i = 2, #self.msgs do
    self.msgs[i-1] = self.msgs[i]
    self.msgColours[i-1] = self.msgColours[i]
  end
  tweenEngine:createTween("logTextY", self.rowheight, 0, 0.5, linearTween)
  tweenEngine:createTween("logAlpha", 255, 0, 0.5, linearTween)


  -- the new message is added to the bottom row
  self.msgs[#self.msgs] = message
  self.msgColours[#self.msgs] = colour

  self.timeStamp = os.time()
  self.blinkTimeStamp = love.timer.getTime()
  self.blinkFlag = true
  self.blinkCounter = 0
  self.blinkPhase = "on"
end
