require("lib.lclass")

class "Entity"

Entity.idCounter = 0

function Entity:Entity()
	Entity.idCounter = Entity.idCounter + 1
	self.id = Entity.idCounter

	self.components = {}
end

function Entity:getId()
	return self.id
end

function Entity:addComponent(component)
	if self:hasComponent(component:getType()) then
		error("has component")
	end
	print("adding "..component:getType())
	self.components[component:getType()] = component
end

function Entity:hasComponent(componentType)
	return self.components[componentType] ~= nil
end

function Entity:getComponent(componentType)
	if not self:hasComponent(componentType) then
		error("could not find component "..componentType)
	end

	return self.components[componentType]
end

function Entity:removeComponent(componentType)
	self.components[componentType] = nil
end
