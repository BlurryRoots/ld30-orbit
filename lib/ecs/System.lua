require("lib.lclass")

class "System"

function System:System()
	self.predicate = nil
end

function System:update(database, camera, dt)	
	self:onUpdate(database, camera, dt)	
end

function System:render(database, camera)
	self:onRender(database, camera)
end
