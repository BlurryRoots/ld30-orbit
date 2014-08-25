require("lib.lclass")
require("lib.ecs.Component")

class "RotationComponent" ("Component")

function RotationComponent:RotationComponent(speed, value)
	self.typeName = "RotationComponent"
	
	self.speed = speed or 0
	self.value = value or 0
end
