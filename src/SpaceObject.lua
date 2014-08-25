require("src.Node")

SpaceObject = {}

function SpaceObject:new(id, gfx, scale, orbit, orbitRadius, orbitSpeed, rotationSpeed)
	local nobj = {}
	
	-- attributes
	nobj.id = id

	nobj.scale = scale

	nobj.gfx = gfx
	nobj.img = nil

	nobj.x = 300
	nobj.y = 300

	nobj.orbit = orbit
	nobj.orbiter = nobj.orbit ~= nil
	nobj.orbAngle = 0
	nobj.orbitRadius = orbitRadius
	nobj.orbitSpeed = orbitSpeed

	nobj.rot = 0
	nobj.rotationSpeed = rotationSpeed

	nobj.green = true

	nobj.node = nil

	-- methods
	nobj.setAngle = function(self, angle)
		self.orbAngle = angle
		self.orbAngle = self.orbAngle % (2 * math.pi)
	end

	nobj.getX = function (self)
		return self.x
	end
	nobj.getY = function (self)	
		return self.y
	end
	nobj.getWidth = function (self)
		return self.img:getWidth() * self.scale
	end
	nobj.getHeight = function (self)
		return self.img:getHeight() * self.scale
	end

	nobj.contains = function (self, x, y, camera)
		local cw = self:getWidth() * camera.zoom.value
		local ch = self:getHeight() * camera.zoom.value
		local cwh = cw / 2
		local chh = ch / 2
		local cx = self:getX() * camera.zoom.value + camera.x * camera.zoom.value
		local cy = self:getY() * camera.zoom.value + camera.y * camera.zoom.value

		local hasx = x >= cx - cwh and x <= cx + cwh
		local hasy = y >= cy - chh and y <= cy + chh

		return hasx and hasy
	end

	nobj.load = function (self)
		self.img = love.graphics.newImage(self.gfx)
	end

	nobj.update = function (self, dt)
		self.x = self.orbit.x + self.orbitRadius * math.sin(self.orbAngle)
		self.y = self.orbit.y + self.orbitRadius * math.cos(self.orbAngle)

		if self.orbitSpeed ~= 0 then
			self:setAngle(self.orbAngle + dt * ((2 * math.pi) / self.orbitSpeed))
		end
		
		if self.rotationSpeed ~= 0 then
			self.rot = self.rot + dt * ((2 * math.pi) / self.rotationSpeed)
			self.rot = self.rot % (2 * math.pi)
		end
	end

	nobj.draw = function (self)
		local hw = self.img:getWidth() / 2
		local hh = self.img:getHeight() / 2

		love.graphics.push()
			love.graphics.setColorMask(true, self.green, true, true)
			love.graphics.push()
				love.graphics.draw(
					self.img, 
					self.x, self.y, 
					self.rot, 
					self.scale, self.scale, 
					hw, hh
				)
			love.graphics.pop()
			love.graphics.setColorMask(true, true, true, true)
		love.graphics.pop()
	end

	nobj.onClick = function (self)
		print(self.id..": dude i got clicked!!!")
		self.green = not self.green
	end

	return nobj
end
