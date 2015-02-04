camera = {
	x = 0,
	y = 0,
	scroll = {
		speed = 780,
		relSpeed = 0,
		fringe = 25
	},
	zoom = {
		speed = 0.05,
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

	--local newZoom = self.zoom.value + dv
	--if newZoom < self.zoom.speed then
	--	newZoom = self.zoom.speed
	--end
	--if newZoom > 2 then
	--	newZoom = 2
	--end

	--Get the mouse coods in camera space:
	--local msx = love.mouse.getX()-- - love.window.getWidth() / 2
	--local msy = love.mouse.getY()-- - love.window.getHeight() / 2

	--Get distances from camera to mouse in camera space
	--local width = self.x - love.window.getWidth() / 2 --msx;
	--local height = self.y -love.window.getHeight() / 2 --msy;

	--Get the offset produced by the new zoom and then substract it to camera position
	--self.x = self.x * (1 - newZoom / self.zoom.value);
	--self.y = self.y * (1 - newZoom / self.zoom.value);

	--self.zoom.value = newZoom;
	

	self:setPosition(love.window.getWidth() / 2 / self.zoom.value, love.window.getHeight() / 2 / self.zoom.value)
end
camera.zoomIn = function (self)
	self:scale(self.zoom.speed)
end
camera.zoomOut = function (self)
	self:scale(-self.zoom.speed)
end
camera.onMouseButtonDown = function (self, button)
	if button == "wu" then
		self:zoomIn()
		print("zoom at "..camera.zoom.value)
	end
	if button == "wd" then
		self:zoomOut()
		print("zoom at "..camera.zoom.value)
	end

end