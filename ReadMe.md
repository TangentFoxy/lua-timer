# timer
Easy timers in Lua. Spiritual successor to kikito's cron.lua

Public domain! Who needs an IP anyhow?

## Usage
Can be *mostly* used as a drop-in replacement for [kikito's cron.lua](https://github.com/kikito/cron.lua),
but that misses the biggest benefit, which is the timer library itself managing
timers, including discarding expired timers:

```lua
timer.after(deadline, function, ...) -- runs once after time
timer.every(interval, function, ...) -- runs repeatedly, every time

timer.update(delta)              -- increment, run functions, discard expired..
```

Functions are completely optional, so you can use the mechanism to track time
rather than execute functions. `timer:get_run_time()` returns the amount of time
since the last interval. (Note: This is only useful for repeating timers.
One-run timers will only count to their `deadline` once, unless manually run.)

A timer can be excluded from `timer.update`, in which case it must be manually
updated:
```lua
local my_timer = timer.every(interval, function, ...)
my_timer:set_manual(true)

my_timer:update(delta)
```

`timer.update` returns a table of expired timers. Example:
```lua
local my_timer = timer.after(deadline, function, ...)

local expired = timer.update(delta)
if expired[my_timer] then
  -- idk, whatever you needed
end
```

Timers can have their run time set to a new value with `my_timer:reset(time)`.
If nothing is passed, they will be set to `0`.

- One-run timers can have their `deadline` changed with
  `my_timer:set_deadline(time)`.
- Repeating timers can have their `interval` changed with
  `my_timer:set_interval(time)`.

---

Incompatibilities / Changes from kikito's cron.lua:
- There are no checks or restrictions on what can be set.
- If a one-run timer is run by `timer.update`, it will *no longer be updated* by
  `timer.update`, even if reset.

## Releases
GitHub unpublishes my releases frequently, check tags to find them!

## Ideas / Tasks
- [ ] Make an import/export format and add save/load functions - resumable timers.
  - [ ] Make it possible to save/load with a unix timestamp. (Dangerous.)
- [x] Make an access function `get_run_time`
- [x] Make functions optional
