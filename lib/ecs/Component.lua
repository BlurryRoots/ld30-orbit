require("lib.lclass")

class "Component"

Component.idCounter = 0

function Component:Component()
	Component.idCounter = Component.idCounter + 1
	self.id = Component.idCounter
	self.typeName = "ERROR"
end

function Component:getId()
	return self.id
end

function Component:getType()
	return self.typeName
end
