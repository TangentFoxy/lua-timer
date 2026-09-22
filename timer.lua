local is_callable = function(callback)
  local _type = type(callback)
  if _type == "function" then return true end
  of _type == "table" then
    local metatable = getmetatable(callback)
    return (type(metatable) == "table") and (type(metatable.__call) == "function")
  end
end

local update_after = function(self, delta)
  if self.running >= self.time then return true end
  self.running = self.running + delta
  if self.running >= self.time then
    self.callback(unpack(self.args))
    return true
  end
end

local update_every = function(self, delta)
  self.running = self.running + delta
  while self.running >= self.time do
    self.callback(unpack(self.args))
    self.running = self.running - self.time
  end
end

local metatable = {
  __index = {
    reset = function(self, time)
      self.running = time or 0
    end,
  },
}

local timers = {}

local new_timer = function(time, callback, update, ...)
  assert(is_callable(callback), "callback function must be callable")

  local timer = setmetatable({
    time = time,
    callback = callback,
    update = update,
    args = {...},
    running = 0,
  }, metatable)

  timers[timer] = timer
  return timer
end

return {
  after = function(time, callback, ...)
    return new_timer(time, callback, update_after, ...)
  end,
  every = function(time, callback, ...)
    return new_timer(time, callback, update_every, ...)
  end,
  update = function(delta)
    local expired = {}
    for timer in pairs(timers) do
      if not timer.manual then
        if timer:update(delta) then
          expired[timer] = true
        end
      end
    end
    for timer in pairs(expired) do
      timers[timer] = nil
    end
    return expired
  end,
}
