camera = {
	x = 0,
	y = 0,
	scroll = {
		speed = 500,
		relSpeed = 0,
		fringe = 25
	},
	zoom = {
		speed = 0.1,
		value = 1.0
	}
}
camera.update = function (self, dt)
	local mx = love.mouse.getX()
	local my = love.mouse.getY()

	self.scroll.relSpeed = self.scroll.speed / self.zoom.value

	if mx < self.scroll.fringe then
		self:translate(self.scroll.relSpeed * dt, 0)
	end
	if mx > love.window.getWidth() - self.scroll.fringe then
		self:translate(-self.scroll.relSpeed * dt, 0)
	end
	if my < self.scroll.fringe then
		self:translate(0, self.scroll.relSpeed * dt)
	end
	if my > love.window.getHeight() - self.scroll.fringe then
		self:translate(0, -self.scroll.relSpeed * dt)
	end
end
camera.translate = function (self, dx, dy)
	self.x = self.x + dx
	self.y = self.y + dy
end
camera.setPosition = function (self, x, y)
	self.x = x
	self.y = y
end
camera.scale = function (self, dv)
	self.zoom.value = self.zoom.value + dv
	if self.zoom.value < self.zoom.speed then
		self.zoom.value = self.zoom.speed
	end
	if self.zoom.value > 2 then
		self.zoom.value = 2
	end
	self:setPosition(love.window.getWidth() / 2 / self.zoom.value, love.window.getHeight() / 2 / self.zoom.value)
end
camera.zoomIn = function (self)
	self:scale(self.zoom.speed)
end
camera.zoomOut = function (self)
	self:scale(-self.zoom.speed)
end
camera.onMouseButtonDown = function (self, button)
	print("speed at "..camera.zoom.speed)
	if button == "wu" then
		self:zoomIn()
		print("zoom at "..camera.zoom.value)
	end
	if button == "wd" then
		self:zoomOut()
		print("zoom at "..camera.zoom.value)
	end

end