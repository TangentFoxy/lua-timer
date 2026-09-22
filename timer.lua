local is_callable = function(callback)
  local _type = type(callback)
  if _type == "function" then return true end
  if _type == "table" then
    local metatable = getmetatable(callback)
    return (type(metatable) == "table") and (type(metatable.__call) == "function")
  end
end

local update_after = function(self, delta)
  if self.run_time >= self.deadline then return true end
  self.run_time = self.run_time + delta
  if self.run_time >= self.deadline then
    self.callback(unpack(self.args))
    return true
  end
end

local update_every = function(self, delta)
  self.run_time = self.run_time + delta
  while self.run_time >= self.interval do
    self.callback(unpack(self.args))
    self.run_time = self.run_time - self.interval
  end
end

local timer_metatable = {
  __index = {
    reset = function(self, time)
      self.run_time = time or 0
    end,
  },
}

local timers = {}

local new_timer = function(callback, update, ...)
  assert(is_callable(callback), "callback function must be callable")

  local timer = setmetatable({
    callback = callback,
    update = update,
    args = {...},
    run_time = 0,
  }, timer_metatable)

  timers[timer] = timer
  return timer
end

return {
  version = "v1.1.0",
  after = function(deadline, callback, ...)
    local timer = new_timer(callback, update_after, ...)
    timer.deadline = deadline
    return timer
  end,
  every = function(interval, callback, ...)
    local timer = new_timer(callback, update_every, ...)
    timer.interval = interval
    return timer
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
