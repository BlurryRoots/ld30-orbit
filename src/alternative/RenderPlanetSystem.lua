require("lib.lclass")
require("lib.ecs.System")

class "RenderPlanetSystem" ("System")

function RenderPlanetSystem:RenderPlanetSystem(assetManager)
	self.predicate = {
		"PositionComponent",
		"PlanetComponent"
	}

	self.assetManager = assetManager
end

function RenderPlanetSystem:onRender(database, camera)
	local candidates = database:filter(self.predicate)
	
	if table.getn(candidates) == 0 then
		error("nonono")
	end

	love.graphics.push()
		love.graphics.scale(camera.zoom.value, camera.zoom.value)
		love.graphics.translate(camera.x, camera.y)

		for _,entity in pairs(candidates) do
			local pl = entity:getComponent("PlanetComponent")
			local po = entity:getComponent("PositionComponent")
			local img = self.assetManager:get(pl.gfx)

			love.graphics.push()
				love.graphics.draw(
					img,
					po.x, po.y, 
					0, 
					1, 1, 
					img:getWidth() / 2, img:getHeight() / 2
				)
			love.graphics.pop()
		end
	love.graphics.pop()
end
