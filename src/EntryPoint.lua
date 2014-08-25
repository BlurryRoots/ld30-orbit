--
require("src.Camera")
require("src.SpaceObject")
require("src.SolarSystem")

function each(l, c)
	for i,v in pairs(l) do
		c(i, v)
	end
end



local massCenter = {
	x = 0,
	y = 0
}
local objs = {}
local background = nil
local system = nil

local menu = {
	attachedTo = nil,
	img = nil,
	contains = function (self, x, y, camera)
		if not self.attachedTo then
			return false
		end

		local cw = self.attachedTo:getWidth() * camera.zoom.value
		local ch = self.attachedTo:getHeight() * camera.zoom.value
		local cx = self.attachedTo:getX() * camera.zoom.value + camera.x * camera.zoom.value
		local cy = self.attachedTo:getY() * camera.zoom.value + camera.y * camera.zoom.value

		local hasx = x >= cx and x <= cx + cw
		local hasy = y >= cy and y <= cy + ch

		return hasx and hasy
	end
}

local selector = {
	attachedTo = nil,
	inner = nil,
	outer = nil,
	contains = function (self, x, y, camera)
		if not self.attachedTo then
			return false
		end

		local cw = self.attachedTo:getWidth() * camera.zoom.value
		local ch = self.attachedTo:getHeight() * camera.zoom.value
		local cx = self.attachedTo:getX() * camera.zoom.value + camera.x * camera.zoom.value
		local cy = self.attachedTo:getY() * camera.zoom.value + camera.y * camera.zoom.value

		local hasx = x >= cx and x <= cx + cw
		local hasy = y >= cy and y <= cy + ch

		return hasx and hasy
	end
}

--
function love.load()
	local prefix = "gfx/256x256"

	menu.img = love.graphics.newImage(prefix.."/Interface/icons.png")

	selector.inner = love.graphics.newImage(prefix.."/Interface/inner_ring.png")
	selector.outer = love.graphics.newImage(prefix.."/Interface/outer_ring.png")

	background = love.graphics.newImage("gfx/starfield.jpg")

	system = SolarSystem:new(0, 0)

	system:createCenterOrbiter(
		"sun",
		prefix.."/Planets/sun.png", 1,
		0, 0,
		0,
		{}
	)
	system:createCenterOrbiter(
		"planet1",
		prefix.."/Planets/planet1.png", 1,
		600, 15,
		8,
		{"planet2", "planet3"}
	)
	system:createOrbiter(
		"planet_moon",
		prefix.."/Moons/grey.png", 0.4,
		"planet1", 300, 8,
		-10,
		{}
	)

	system:createCenterOrbiter(
		"planet2",
		prefix.."/Planets/planet2.png", 1,
		1200, 40,
		5,
		{}
	)

	system:createCenterOrbiter(
		"planet3",
		prefix.."/Planets/planet4.png", 1,
		1600, 45,
		5,
		{"planet4"}
	)
	system:createOrbiter(
		"planet3_moon",
		prefix.."/Moons/grey.png", 0.4,
		"planet3", 300, 4,
		3,
		{}
	)

	system:createCenterOrbiter(
		"planet4",
		prefix.."/Planets/planet5.png", 1,
		2100, 52,
		12,
		{"planet5"}
	)

	system:createCenterOrbiter(
		"planet5",
		prefix.."/Planets/planet6.png", 1,
		2600, 64,
		20,
		{}
	)

	system:foreach(function (i, v)
		v:load()
	end)

	camera:setPosition(love.window.getWidth() / 2, love.window.getHeight() / 2)
end

function love.quit()
end

--
function love.focus(f)
end

function love.resize(w, h)
	camera:setPosition(love.window.getWidth() / 2, love.window.getHeight() / 2)
end

--
function love.update(dt)
	camera:update(dt)
	system:update(dt)
end

function love.draw()
	local bgw = background:getWidth()
	local bgh = background:getHeight()
	local ww = love.window.getWidth()
	local wh = love.window.getWidth()

	love.graphics.draw(background, 0, 0, 0, ww / bgw, wh / bgh)

	love.graphics.push()
		love.graphics.scale(camera.zoom.value, camera.zoom.value)
		love.graphics.translate(camera.x, camera.y)

		love.graphics.push()
			system:draw()
		love.graphics.pop()

		if selector.attachedTo ~= nil then
			love.graphics.push()
				love.graphics.draw(
					selector.outer, 
					selector.attachedTo.x, selector.attachedTo.y, 
					0, 
					selector.attachedTo.scale, selector.attachedTo.scale, 
					selector.outer:getWidth() / 2, selector.outer:getHeight() / 2
				)
				love.graphics.draw(
					selector.inner, 
					selector.attachedTo.x, selector.attachedTo.y, 
					0, 
					selector.attachedTo.scale, selector.attachedTo.scale, 
					selector.inner:getWidth() / 2, selector.inner:getHeight() / 2
				)
			love.graphics.pop()
		end
		if menu.attachedTo ~= nil then
			love.graphics.draw(menu.img, menu.attachedTo.x, menu.attachedTo.y)
		end
	love.graphics.pop()
end

--
function love.mousepressed(x, y, button)
	camera:onMouseButtonDown(button)
end

function love.mousereleased(x, y, button)
	if button == "l" then
		if menu.attachedTo ~= nil and menu:contains(x, y, camera) then
			print("jojwojwoj")
		end

		system:foreach(function(i,v)
			if v:contains(x, y, camera) then
				--v:onClick()
				menu.attachedTo = v
				selector.attachedTo = v
			end
		end)
	end
end

function love.keypressed(key)
end

function love.keyreleased(key)
end
