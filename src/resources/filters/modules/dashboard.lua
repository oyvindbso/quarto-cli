-- dashboard.lua
-- Copyright (C) 2020-2022 Posit Software, PBC

local layout = require 'modules/dashboard/layout'
local card = require 'modules/dashboard/card'
local valuebox = require 'modules/dashboard/valuebox'
local sidebar = require 'modules/dashboard/sidebar'


-- param name
local kParamKey = "dashboard"

-- Layout param
local kLayoutFill = "fill"

-- Orientation param
local kParamOrientation = "orientation"
local kDefaultOrientation = kOrientationRows


local function dashboardParam(name, default) 
  local dashboardParams = param(kParamKey, {})
  return dashboardParams[name] or default
end

local function isLayoutContainer(el)
  if card.isCard(el) then
    return true
  elseif valuebox.isValueBox(el) then
    return true
  elseif layout.isRowOrColContainer(el) then
    return true
  elseif sidebar.isSidebar(el) then
    return true
  end
  return false
end


local function organizer(contents, ignoreClasses) 

  -- ignore any elements which contain these classes
  ignoreClasses = ignoreClasses or pandoc.List()

  local function isIgnored(el)
    if el.classes ~= nil then
      return el.classes:find_if(function(class) 
        return ignoreClasses:includes(class)
      end) 
    end
    return false
  end
  
  -- Make sure everything is in a card
  local layoutContentEls = pandoc.List()
  local looseContentEls = pandoc.List()
  local function flushLooseContent() 
    if #looseContentEls > 0 then
      local cardOptions = card.readCardOptions(looseContentEls[1])
      layoutContentEls:insert(card.makeCard(nil, looseContentEls, {}, cardOptions))              
      looseContentEls = pandoc.List()
      end
  end

  return {
    ensureInLayoutContainers = function()
      for i, v in ipairs(contents) do
        if not isLayoutContainer(v) and not isIgnored(v) then
          looseContentEls:insert(v)
        else
          flushLooseContent()
          layoutContentEls:insert(v)
        end
      end
      flushLooseContent()    
      return layoutContentEls
    end
  }
end


return {
  layout = layout,
  card = card,
  valuebox = valuebox,
  sidebar = sidebar,
  document = {
    fill = dashboardParam(kLayoutFill, true),
    orientation = dashboardParam(kParamOrientation, kDefaultOrientation)
  },
  layoutContainer = {
    organizer = organizer
  }
}