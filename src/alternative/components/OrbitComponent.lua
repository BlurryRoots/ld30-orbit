require("lib.lclass")
require("lib.ecs.Component")

class "OrbitComponent" ("Component")

function OrbitComponent:OrbitComponent()
	self.typeName = "OrbitComponent"

	self.origin = {
		x = 0, 
		y = 0
	}
	self.angle = 0
	self.radius = 0
	self.speed = 0
end
