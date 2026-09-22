# timer
Easy timers in Lua. Spiritual successor to kikito's cron.lua

Public domain! Who needs an IP anyhow?

## Usage
Can be *mostly* used as a drop-in replacement for [kikito's cron.lua](https://github.com/kikito/cron.lua),
but that misses the biggest benefit, which is the timer library itself managing
timers, including discarding expired timers:

```lua
timer.after(time, function, ...) -- runs once after time
timer.every(time, function, ...) -- runs repeatedly, every time

timer.update(delta)              -- increment, run functions, discard expired..
```

A timer can be excluded from `timer.update`, in which case it must be manually
updated:
```lua
local my_timer = timer.every(time, function, ...)
my_timer.manual = true

my_timer:update(delta)
```

`timer.update` returns a table of expired timers. Example:
```lua
local my_timer = timer.after(time, function, ...)

local expired = timer.update(delta)
if expired[my_timer] then
  -- idk, whatever you needed
end
```

Timers can have their time set to a new value with `my_timer:reset(time)`. If
nothing is passed, they will be set to `0`.

---

Incompatibilities / Changes from kikito's cron.lua:
- Number values are not checked or restricted.
- Different error message for callback not being callable.
- If a one-time timer is run by `timer.update`, it will *no longer be updated*
  by `timer.update`, even if reset.

## Ideas / Tasks
- [ ] Make an import/export format and add save/load functions - resumable timers.
  - [ ] Make it possible to save/load with a unix timestamp. (Dangerous.)
