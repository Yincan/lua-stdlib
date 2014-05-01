------
-- @module std.base


--- Write a deprecation warning to stderr on first call.
-- @func        fn      deprecated function
-- @string[opt] name    function name for automatic warning message.
-- @string[opt] warnmsg full specified warning message (overrides *name*)
-- @return a function to show the warning on first call, and hand off to *fn*
local function deprecate (fn, name, warnmsg)
  assert (name or warnmsg,
          "missing argument to 'deprecate', expecting 2 or 3 parameters")
  warnmsg = warnmsg or (name .. " is deprecated, and will go away in a future release.")
  local warnp = true
  return function (...)
    if warnp then
      local _, where = pcall (function () error ("", 4) end)
      io.stderr:write ((string.gsub (where, "(^w%*%.%w*%:%d+)", "%1")))
      io.stderr:write (warnmsg .. "\n")
      warnp = false
    end
    return fn (...)
  end
end


-- Doc-commented in table.lua...
local function metamethod (x, n)
  local _, m = pcall (function (x)
                        return getmetatable (x)[n]
                      end,
                      x)
  if type (m) ~= "function" then
    m = nil
  end
  return m
end


-- Doc-commented in table.lua...
local function merge (t, u, map, nometa)
  assert (type (t) == "table",
          "bad argument #1 to 'merge' (table expected, got " .. type (t) .. ")")
  assert (type (u) == "table",
          "bad argument #2 to 'merge' (table expected, got " .. type (u) .. ")")
  map = map or {}
  if type (map) ~= "table" then
    map, nometa = {}, map
  end

  if not nometa then
    setmetatable (t, getmetatable (u))
  end
  for k, v in pairs (u) do
    t[map[k] or k] = v
  end
  return t
end

-- Doc-commented in list.lua...
local function append (l, x)
  local r = {unpack (l)}
  table.insert (r, x)
  return r
end

-- Doc-commented in list.lua...
local function compare (l, m)
  for i = 1, math.min (#l, #m) do
    if l[i] < m[i] then
      return -1
    elseif l[i] > m[i] then
      return 1
    end
  end
  if #l < #m then
    return -1
  elseif #l > #m then
    return 1
  end
  return 0
end

-- Doc-commented in list.lua...
local function elems (l)
  local n = 0
  return function (l)
           n = n + 1
           if n <= #l then
             return l[n]
           end
         end,
  l, true
end

--- Concatenate lists.
-- @param ... lists
-- @return `{l<sub>1</sub>[1], ...,
-- l<sub>1</sub>[#l<sub>1</sub>], ..., l<sub>n</sub>[1], ...,
-- l<sub>n</sub>[#l<sub>n</sub>]}`
local function concat (...)
  local r = {}
  for l in elems ({...}) do
    for v in elems (l) do
      table.insert (r, v)
    end
  end
  return r
end

local function _leaves (it, tr)
  local function visit (n)
    if type (n) == "table" then
      for _, v in it (n) do
        visit (v)
      end
    else
      coroutine.yield (n)
    end
  end
  return coroutine.wrap (visit), tr
end

-- Doc-commented in tree.lua...
local function ileaves (tr)
  assert (type (tr) == "table",
          "bad argument #1 to 'ileaves' (table expected, got " .. type (tr) .. ")")
  return _leaves (ipairs, tr)
end

-- Doc-commented in tree.lua...
local function leaves (tr)
  assert (type (tr) == "table",
          "bad argument #1 to 'leaves' (table expected, got " .. type (tr) .. ")")
  return _leaves (pairs, tr)
end

local M = {
  append       = append,
  compare      = compare,
  concat       = concat,
  deprecate    = deprecate,
  elems        = elems,
  ileaves      = ileaves,
  leaves       = leaves,
  merge        = merge,
  metamethod   = metamethod,
}

return M
