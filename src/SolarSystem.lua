require("src.SpaceObject")

SolarSystem = {}

function SolarSystem:new(centerX, centerY)
	local nobj = {
		center = {
			x = centerX or 0,
			y = centerY or 0
		},
		objectList = {},
		graph = {},
		totalHardening = 0
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
		sobj.reNodeList = reNodeList
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
		sobj.reNodeList = reNodeList
		local r = love.math.random(2 * math.pi)
		sobj:setAngle(r)

		table.insert(self.objectList, sobj)
	end

	nobj.foreach = function (self, callback)
		for i, v in pairs(self.objectList) do
			callback(self, i, v)
		end
	end

	nobj.update = function (self, dt)
		self.totalHardening = 0

		self:foreach(function (self, i, v)
			v:update(dt)

			if v.node ~= nil then
				v.node:update(dt)

				self.totalHardening = self.totalHardening + v.node.hardening

				if v.node.status.hacked then
					if table.getn(v.nodeList) == 0 then
						return
					end

					for _,childName in pairs(v.nodeList) do
						local child = self:getObjectByName(childName)
						if child.node ~= nil then
							child.node.status.hackable = true
						end
					end
				end
			end
		end)
	end

	nobj.renderConnections = function (self, start, nodes)
		local n = table.getn(nodes)
		if n == 0 then
			return false
		end

		for i,v in ipairs(nodes) do
			local object = self:getObjectByName(v)

			love.graphics.setLineWidth(42)
			if object.node.status.hackable then
				love.graphics.setColor(255, 255, 255, 255)
			else
				love.graphics.setColor(255, 255, 255, 32)
			end
			love.graphics.line(start.x, start.y, object.x, object.y)
			love.graphics.setColor(255, 255, 255, 255)

			self:renderConnections(object, object.nodeList)
		end

		return true
	end

	return nobj
end