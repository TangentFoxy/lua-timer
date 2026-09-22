-- This file is public domain. Created by Tangent, the fox, the legend.

local update_after = function(self, delta)
  if self.run_time >= self.deadline then return true end
  self.run_time = self.run_time + delta
  if self.run_time >= self.deadline then
    if self.callback then
      self.callback(unpack(self.args))
    end
    return true
  end
end

local update_every = function(self, delta)
  self.run_time = self.run_time + delta
  while self.run_time >= self.interval do
    if self.callback then
      self.callback(unpack(self.args))
    end
    self.run_time = self.run_time - self.interval
  end
end

local timer_metatable = {
  __index = {
    get_run_time = function(self)
      return self.run_time
    end,
    reset = function(self, time)
      self.run_time = time or 0
    end,
    set_deadline = function(self, deadline)
      assert(self.deadline, "set_deadline() is only for timer.after() timers.")
      self.deadline = deadline
    end,
    set_interval = function(self, interval)
      assert(self.interval, "set_interval() is only for timer.every() timers.")
      self.interval = interval
    end,
  },
}

local timers = {}

local new_timer = function(callback, update, ...)
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
  version = "v1.2.0",
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
