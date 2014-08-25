require("src.SpaceObject")

SolarSystem = {}

function SolarSystem:new(centerX, centerY)
	local nobj = {
		center = {
			x = centerX or 0,
			y = centerY or 0
		},
		objectList = {},
		graph = {}
	}

	nobj.getObjectByName = function (self, name)
		local obj = nil
		for i, v in pairs(self.objectList) do
			if name == v.id then
				obj = v
				break
			end
		end
		return obj
	end

	nobj.createCenterOrbiter = function (self, name, gfx, scale, orbitRadius, orbitSpeed, rotationSpeed, nodeList)
		local sobj = SpaceObject:new(
			name, gfx, scale,
			self.center, orbitRadius, orbitSpeed,
			rotationSpeed
		)
		sobj.nodeList = nodeList
		local r = love.math.random(2 * math.pi)
		sobj:setAngle(r)

		table.insert(self.objectList, sobj)
	end

	nobj.createOrbiter = function (self, name, gfx, scale, centerName, orbitRadius, orbitSpeed, rotationSpeed, nodeList)
		local orbit = self:getObjectByName(centerName)
		if not orbit then
			error("SolarSystem: I have no object called "..centerName)
		end

		local sobj = SpaceObject:new(
			name, gfx, scale,
			orbit, orbitRadius, orbitSpeed,
			rotationSpeed
		)
		sobj.nodeList = nodeList
		local r = love.math.random(2 * math.pi)
		sobj:setAngle(r)

		table.insert(self.objectList, sobj)
	end

	nobj.foreach = function (self, callback)
		for i, v in pairs(self.objectList) do
			callback(i, v)
		end
	end

	nobj.update = function (self, dt)
		self:foreach(function (i, v)
			v:update(dt)
		end)
	end

	nobj.renderNodes = function (self, start, nodes)
		local n = table.getn(nodes)
		if n == 0 then
			return false
		end

		for i,v in ipairs(nodes) do
			local node = self:getObjectByName(v)
			love.graphics.line(start.x, start.y, node.x, node.y)
			self:renderNodes(node, node.nodeList)
		end

		return true
	end

	nobj.draw = function (self)
		self:foreach(function (i, v)
			v:draw()
			self:renderNodes(v, v.nodeList)
		end)		
	end

	return nobj
end