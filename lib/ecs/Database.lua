require("lib.lclass")

class "Database"

function Database:Database()
	self.entities = {}
end

function Database:add(entity)
	table.insert(self.entities, entity)
end

function Database:filter(predicate)
	local candidates = {}

	for _,entity in ipairs(self.entities) do
		local hasall = true
		for _,p in ipairs(predicate) do
			hasall = hasall and entity:hasComponent(p)
		end
		if hasall then
			table.insert(candidates, entity)
		end
	end

	return candidates
end

function Database:getById(id)
	local match = nil

	for _,entity in pairs(self.entities) do
		if entity.id == id then
			match = entity
			break
		end
	end

	return match
end
