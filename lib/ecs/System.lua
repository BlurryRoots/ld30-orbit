require("lib.lclass")

class "System"

function System:System()
	self.predicate = nil
end

function System:render(database, camera)
	local candidates = {}

	for _,entity in ipairs(database) do
		local hasall = true
		for _,p in ipairs(self.predicate) do
			hasall = hasall and entity:hasComponent(p)
		end
		if hasall then
			table.insert(candidates, entity)
		end
	end

	self:onRender(candidates, camera)
end
