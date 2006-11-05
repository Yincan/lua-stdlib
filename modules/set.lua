-- @module set

module ("set", package.seeall)

require "object"
require "table_ext"


-- Primitive methods (access the underlying representation)

-- The representation is a table whose tags are the elements, and
-- whose values are true.

-- @func member: Say whether an element is in a set
--   @param e: element
-- @returns
--   @param f: true if e is in set, false otherwise
function member (e)
  return self[e] == true
end

-- @func add: Add an element to a set
--   @param e: element
function add (e)
  self[e] = true
end

-- @func new: Make a list into a set
--   @param l: list
-- @returns
--   @param s: set
function new (l)
  local s = {}
  for _, v in ipairs (l) do
    s:add (true)
  end
  return s
end


-- High level methods (no knowledge of representation)

-- @func minus: Find the difference of two sets
--   @param t: set
-- @returns
--   @param r: self with elements of t removed
function minus (t)
  local r = new {}
  for e in self:pairs () do
    if not t:member (e) then
      r:add (e)
    end
  end
  return r
end

-- @func intersect: Find the intersection of two sets
--   @param t: set
-- @returns
--   @param r: set intersection of self and t
function intersect (t)
  local r = new {}
  for e in self:pairs () do
    if t:member (e) then
      r:add (e)
    end
  end
  return r
end

-- @func union: Find the union of two sets
--   @param t: set
-- @returns
--   @param r: set union of self and t
function union (t)
  local r = new {}
  r.set = table.merge (self.set, t.set)
  return r
end

-- @func subset: Find whether one set is a subset of another
--   @param t: set
-- @returns
--   @param r: true if self is a subset of t, false otherwise
function subset (t)
  for e in self:pairs () do
    if not t:member (e) then
      return false
    end
  end
  return true
end

-- @func propersubset: Find whether one set is a proper subset of
-- another
--   @param t: set
-- @returns
--   @param r: true if s is a proper subset of t, false otherwise
function propersubset (t)
  return self:subset (t) and not t:subset (self)
end

-- @func equal: Find whether two sets are equal
--   @param t: set
-- @returns
--   @param r: true if sets are equal, false otherwise
function equal (t)
  return self:subset (t) and t:subset (self)
end

-- Metamethods
-- set + table = union
getmetatable (_M).__add = union
-- set - table = set difference
getmetatable (_M).__sub = minus
-- set / table = intersection
getmetatable (_M).__div = intersect
-- set <= table = subset
getmetatable (_M).__le = subset
-- set < table = proper subset
getmetatable (_M).__lt = propersubset