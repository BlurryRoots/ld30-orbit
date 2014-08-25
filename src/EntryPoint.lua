--
require("src.Camera")
require("src.SpaceObject")
require("src.SolarSystem")
require("src.EventManager")


player = {
	img = nil,
	detected = false,
	handle = function(self, event)
		print("handling event "..event.typeName)
		if event.typeName == "player.detected" and not self.detected then
			self.detected = true
			sounds["detected"]:play()
		end
	end
}
sounds = {}

eventManager = nil

isRunnig = true

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



local dfont = nil
local ffont = nil

local debugHandler = {
	handle = function(self, event)
		print("handling "..event.typeName)
	end
}

--
function love.load()
	eventManager = EventManager()

	eventManager:subscribe("player.detected", debugHandler)
	eventManager:subscribe("hack.started", debugHandler)
	eventManager:subscribe("hack.finished", debugHandler)
	eventManager:subscribe("player.detected", player)

	dfont = love.graphics.newFont("gfx/tekn.ttf", 128)
	ffont = love.graphics.newFont("gfx/tekn.ttf", 96)

	local prefix = "gfx/256x256"

	menu.img = love.graphics.newImage("gfx/Interface/icons.png")

	selector.inner = love.graphics.newImage("gfx/Interface/inner_ring.png")
	selector.outer = love.graphics.newImage("gfx/Interface/outer_ring.png")

	background = love.graphics.newImage("gfx/starfield.jpg")

	sounds["fortify"] = love.audio.newSource("sfx/171499__fins__logged-in.wav", "static")
	sounds["hack"] = love.audio.newSource("sfx/172203__fins__menu-button.wav", "static")
	sounds["click"] = love.audio.newSource("sfx/173328__soundnimja__blip-1.wav", "static")
	sounds["detected"] = love.audio.newSource("sfx/193943__theevilsocks__menu-select.wav", "static")
	sounds["success"] = love.audio.newSource("sfx/243020__plasterbrain__game-start.ogg", "static")

	system = SolarSystem:new(0, 0)

	local e = nil

	system:createCenterOrbiter(
		"sun",
		"gfx/Planets/sun.png", 2,
		0, 0,
		0,
		{}
	)

	system:createCenterOrbiter(
		"planet1",
		"gfx/Planets/planet1.png", 1,
		600, 15,
		8,
		{"planet2", "planet3"}
	)
	e = system:getObjectByName("planet1")
	e.node = Node(0.01, 2, Node.Category.Normal)
	e.node.status.available = true
	e.node.status.hackable = true

	system:createOrbiter(
		"planet_moon",
		"gfx/Moons/grey.png", 0.4,
		"planet1", 300, 8,
		-10,
		{}
	)

	system:createCenterOrbiter(
		"planet2",
		"gfx/Planets/planet2.png", 1,
		1200, 40,
		5,
		{}
	)
	e = system:getObjectByName("planet2")
	e.node = Node(0.9, 1, Node.Category.Storage)
	e.node.status.available = true

	system:createCenterOrbiter(
		"planet3",
		"gfx/Planets/planet4.png", 1,
		1600, 45,
		5,
		{"planet4"}
	)
	e = system:getObjectByName("planet3")
	e.node = Node(0.1, 1, Node.Category.Utility)
	e.node.status.available = true

	system:createOrbiter(
		"planet3_moon",
		"gfx/Moons/grey.png", 0.4,
		"planet3", 300, 4,
		3,
		{}
	)

	system:createCenterOrbiter(
		"planet4",
		"gfx/Planets/planet5.png", 1,
		2100, 52,
		12,
		{"planet5"}
	)
	e = system:getObjectByName("planet4")
	e.node = Node(0.1, 1, Node.Category.Target)
	e.node.status.available = true

	system:createCenterOrbiter(
		"planet5",
		"gfx/Planets/planet6.png", 1,
		2600, 64,
		20,
		{}
	)
	e = system:getObjectByName("planet5")
	e.node = Node(0.1, 1, Node.Category.Firewall)
	e.node.status.available = true

	system:createCenterOrbiter(
		"player",
		"gfx/Interface/spaceship.png", 1,
		3000, -64,
		32,
		{"planet1"}
	)
	e = system:getObjectByName("player")
	--e.rot = -math.pi / 2
	e.node = Node(0.0, 0, Node.Category.Home)
	e.node.status.available = true
	e.node.status.hacked = true
	e.node.status.fortified = true

	system:foreach(function (self, i, v)
		v:load()
	end)

	camera:setPosition(love.window.getWidth() / 2, love.window.getHeight() / 2)
end

function love.quit()
end

--
function love.focus(f)
	isRunnig = f
end

function love.resize(w, h)
	camera:setPosition(love.window.getWidth() / 2, love.window.getHeight() / 2)
end

--
function love.update(dt)
	if not isRunnig then
		return
	end

	eventManager:update(dt)
	camera:update(dt)
	system:update(dt)
end

function love.draw()
	local bgw = background:getWidth()
	local bgh = background:getHeight()
	local ww = love.window.getWidth()
	local wh = love.window.getWidth()

	local r, g, b, a = love.graphics.getColor()
	local font = love.graphics.getFont()

	love.graphics.draw(background, 0, 0, 0, ww / bgw, wh / bgh)

	love.graphics.push()
		love.graphics.scale(camera.zoom.value, camera.zoom.value)
		love.graphics.translate(camera.x, camera.y)

		love.graphics.push()
			system:foreach(function (self, i, v)
				self:renderConnections(v, v.nodeList)
			end)
		love.graphics.pop()

		love.graphics.push()
			system:foreach(function (self, i, v)
				v:draw()
			end)
		love.graphics.pop()

		love.graphics.push()
			system:foreach(function (self, i, v)
				if v.node == nil then
					return
				end

				love.graphics.setFont(dfont)

				love.graphics.print(
					v.node.difficulty,
					v.x + selector.inner:getWidth() / 2 * v.scale,
					v.y - selector.inner:getHeight() / 2 * v.scale
				)

				if v.node.category == Node.Category.Target then
					love.graphics.setColor(255, 255, 64, 255)
				elseif v.node.category == Node.Category.Firewall then
					love.graphics.setColor(255, 0, 0, 255)
				else					
					love.graphics.setColor(0, 128, 128, 255)
				end
				love.graphics.print(
					v.node.category,
					v.x - selector.inner:getWidth() / 2 * v.scale,
					v.y + selector.inner:getHeight() / 2 * v.scale
				)

				love.graphics.setColor(r, g, b, a)

				if v.node.status.hacked then
					love.graphics.draw(
						selector.outer,
						v.x, v.y, 
						0,
						v.scale * 0.8, v.scale * 0.8, 
						selector.outer:getWidth() / 2, selector.outer:getHeight() / 2
					)
					love.graphics.draw(
						selector.inner,
						v.x, v.y, 
						0,
						v.scale, v.scale, 
						selector.inner:getWidth() / 2, selector.inner:getHeight() / 2
					)
				end

				if v.node.status.fortified then
					love.graphics.draw(
						selector.outer,
						v.x, v.y, 
						0,
						v.scale, v.scale, 
						selector.outer:getWidth() / 2, selector.outer:getHeight() / 2
					)
				end

				if v.node.status.selected then
					love.graphics.draw(
						menu.img,
						v.x + v.img:getWidth() / 2,
						v.y + v.img:getHeight() / 2
					)
				end
			end)		
		love.graphics.pop()
	love.graphics.pop()

	love.graphics.setFont(ffont)
	if player.detected then
		love.graphics.setColor(255, 0, 0, 255)
		love.graphics.print("Detected!", 42, 42)
	else
		love.graphics.setColor(0, 255, 0, 255)
		love.graphics.print("Undetected.", 42, 42)
	end
	love.graphics.setColor(255, 255, 255, 255)
end

--
function love.mousepressed(x, y, button)
	camera:onMouseButtonDown(button)
end

function love.mousereleased(x, y, button)
	if button == "l" then
		system:foreach(function(self, i,v)
			if v.node ~= nil then
				if v:contains(x, y, camera) then
					sounds["click"]:play()
					v.node:toggleSelect()
				else
					v.node:unselect()					
				end
			end
		end)
	end

	if button == "r" then
		system:foreach(function(self, i,v)
			if v:contains(x, y, camera) and v.node ~= nil then
				if v.node.status.selected then
					if v.node.status.hacked then
						v.node:fortify()
					else
						v.node:hack()
					end
				end
			end
		end)
	end
end

function love.keypressed(key)
end

function love.keyreleased(key)
	if key == "escape" then
		love.event.quit()
	end
	if key == " " then
		isRunnig = not isRunnig
	end
	if key == "f1" then
		local fs = love.window.getFullscreen()
		love.window.setFullscreen(not fs)
	end
end
