require("lib.lclass")
require("lib.ecs.Component")

class "PositionComponent" ("Component")

function PositionComponent:PositionComponent(x, y)
	self.typeName = "PositionComponent"

	self.x = x or 0
	self.y = y or 0
end

function PositionComponent:getX()
	return self.x
end

function PositionComponent:getX()
	return self.y
end
