require("lib.lclass")
require("lib.ecs.System")

class "SpaceObjectInputSystem" ("System")

function SpaceObjectInputSystem:SpaceObjectInputSystem(assetManager)
	self.predicate = {
		"PositionComponent",
		"PlanetComponent"
	}

	self.assetManager = assetManager
	self.clickEvents = {}
end

function SpaceObjectInputSystem:onUpdate(database, camera, dt)
	local candidates = database:filter(self.predicate)

	if table.getn(candidates) == 0 then
		return
	end

	while table.getn(self.clickEvents) > 0 do
		local event = table.remove(self.clickEvents)

		for _,entity in pairs(candidates) do
			local pos = entity:getComponent("PositionComponent")
			local pla = entity:getComponent("PlanetComponent")
			local img = self.assetManager:get(pla.gfx)

			local cw = img:getWidth() * camera.zoom.value
			local ch = img:getHeight() * camera.zoom.value
			local cwh = cw / 2
			local chh = ch / 2
			local cx = pos.x * camera.zoom.value + camera.x * camera.zoom.value
			local cy = pos.y * camera.zoom.value + camera.y * camera.zoom.value

			local hasx = event.x >= cx - cwh and event.x <= cx + cwh
			local hasy = event.y >= cy - chh and event.y <= cy + chh

			if hasx and hasy then
				self:handleClick(entity)
			end
		end
	end
end

function SpaceObjectInputSystem:onRender(candidates, camera)
	if table.getn(candidates) == 0 then
		error("nonono")
	end
end

function SpaceObjectInputSystem:handleClick(entity)
	print("clickerei")
end

function SpaceObjectInputSystem:mousepressed(x, y, button)
	if button == "l" then
		table.insert(self.clickEvents, {
			x = x,
			y = y
		})
	end
end
