require("lib.lclass")
require("lib.ecs.Component")

class "PlanetComponent" ("Component")

function PlanetComponent:PlanetComponent(gfx)
	self.typeName = "PlanetComponent"
	
	self.gfx = gfx or ""
end
