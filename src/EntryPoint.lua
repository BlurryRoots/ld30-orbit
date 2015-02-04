--
require("src.Camera")
require("src.SpaceObject")
require("src.SolarSystem")
require("src.EventManager")

function round(num, idp)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end

function each(l, c)
	for i,v in pairs(l) do
		c(i, v)
	end
end

function globalSetupShit()
	ai = {
		home = nil,
		active = false,
		time = {
			fraction = 0.6,
			value = 0,
			passed = 0
		},
		activate = function(self)
			self.active = true
			print("activating ai")
			eventManager:push({
				typeName = "ai.activated",
			})
		end,
		update = function(self, system, dt)
			self.time.value = system.totalHardening * self.time.fraction

			if self.time.passed > self.time.value then
				eventManager:push({
					typeName = "ai.timeisup"
				})
			end

			if self.active then
				self.time.passed = self.time.passed + dt
			end
		end,
		reset = function(self)
			self.home = nil
			self.active = false
			self.time = {
				fraction = 0.6,
				value = 0,
				passed = 0
			}
		end,
	}

	player = {
		img = nil,
		detected = false,
		handle = function(self, event)
			print("handling event "..event.typeName)
			if event.typeName == "player.detected" and not self.detected then
				self.detected = true
				sounds["detected"]:play()
				ai:activate()
			end
		end
	}

	sounds = {}

	eventManager = nil

	isRunnig = true

	massCenter = {
		x = 0,
		y = 0
	}
	objs = {}
	background = nil
	system = nil

	menu = {
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

	selector = {
		attachedTo = nil,
		inner = nil,
		outer = nil,
		contains = function (self, x, y, camera)
			if not self.attachedTo then
				return false
			end

			local cw = self.attachedTo:getWidth() * camera.zoom.value
			local ch = self.attachedTo:getHeight() * camera.zoom.value
			local cx = (self.attachedTo:getX() + camera.x) * camera.zoom.value
			local cy = (self.attachedTo:getY() + camera.y) * camera.zoom.value

			local hasx = x >= cx and x <= cx + cw
			local hasy = y >= cy and y <= cy + ch

			return hasx and hasy
		end
	}

	debugHandler = {
		handle = function(self, event)
			print("handling "..event.typeName)
		end
	}

	dfont = nil
	ffont = nil

	bonusHandler = {
		handle = function(self, event)
			if event.typeName == "hack.finished" then
				if event.node.category == Node.Category.Storage then
					eventManager:push({
						typeName = "difficulty.decrease",
						value = 1
					})
				end
			end
			if event.typeName == "difficulty.decrease" then
				print("decreasing difficulty")
				system:foreach(function (self, i, v)
					if v.node ~= nil then
						v.node.difficulty = v.node.difficulty - event.value
						if v.node.difficulty < 0 then
							v.node.difficulty = 0
						end
					end
				end)
			end
		end
	}

	winningHandler = {
		state = "undecided",
		targetsOnMap = 1,
		targetsHacked = 0,
		handle = function(self, event)
			if event.typeName == "hack.finished" then
				if event.node.category == Node.Category.Firewall then
					self.state = "win"
					sounds["win"]:play()
				end
				if event.node.category == Node.Category.Target then
					self.targetsHacked = self.targetsHacked + 1
					if self.targetsHacked >= self.targetsOnMap then
						self.state = "win"
						sounds["win"]:play()
					end
				end			
			end
			if event.typeName == "ai.timeisup" then
				self.state = "fail"
				sounds["fail"]:play()
			end
		end
	}

	soundHandler = {
		handle = function(self, event)
			if event.typeName == "hack.finished" then
				sounds["hack"]:play()
			end
			if event.typeName == "fortify.finished" then
				sounds["fortify"]:play()
			end
		end	
	}

	icons = {}
end

function baseSetup()
	eventManager = EventManager()

	eventManager:subscribe("player.detected", debugHandler)
	eventManager:subscribe("hack.started", debugHandler)
	eventManager:subscribe("hack.finished", debugHandler)
	eventManager:subscribe("trace.started", debugHandler)
	eventManager:subscribe("trace.finished", debugHandler)
	eventManager:subscribe("ai.activated", debugHandler)
	
	eventManager:subscribe("hack.finished", bonusHandler)
	eventManager:subscribe("difficulty.decrease", bonusHandler)	

	eventManager:subscribe("hack.finished", winningHandler)
	eventManager:subscribe("ai.timeisup", winningHandler)
	
	eventManager:subscribe("player.detected", player)

	eventManager:subscribe("hack.finished", soundHandler)
	eventManager:subscribe("fortify.finished", soundHandler)

	dfont = love.graphics.newFont("gfx/Fonts/VeraMono.ttf", 64)
	ffont = love.graphics.newFont("gfx/Fonts/VeraMono.ttf", 96)

	menu.img = love.graphics.newImage("gfx/Interface/icons.png")

	selector.inner = love.graphics.newImage("gfx/Interface/inner_ring.png")
	selector.outer = love.graphics.newImage("gfx/Interface/outer_ring.png")

	background = love.graphics.newImage("gfx/starfield.jpg")

	sounds["fortify"] = love.audio.newSource("sfx/171499__fins__logged-in.wav", "static")
	sounds["fortify"]:setVolume(0.3)
	sounds["hack"] = love.audio.newSource("sfx/172203__fins__menu-button.wav", "static")
	sounds["click"] = love.audio.newSource("sfx/173328__soundnimja__blip-1.wav", "static")
	sounds["detected"] = love.audio.newSource("sfx/193943__theevilsocks__menu-select.wav", "static")
	sounds["success"] = love.audio.newSource("sfx/243020__plasterbrain__game-start.ogg", "static")
	sounds["success"]:setVolume(0.9)
	--sounds["win"] = love.audio.newSource("sfx/52908__m-red__winning.mp3", "static")
	sounds["win"] = love.audio.newSource("sfx/171670__fins__success-2.wav", "static")
	sounds["fail"] = love.audio.newSource("sfx/159408__noirenex__lifelost.wav", "static")

	icons[Node.Category.Home] = love.graphics.newImage("gfx/Interface/home.png")
	icons[Node.Category.Normal] = love.graphics.newImage("gfx/Interface/antenna.png")
	icons[Node.Category.Utility] = love.graphics.newImage("gfx/Interface/utility.png")
	icons[Node.Category.Storage] = love.graphics.newImage("gfx/Interface/storage.png")
	icons[Node.Category.Target] = love.graphics.newImage("gfx/Interface/target.png")
	icons[Node.Category.Firewall] = love.graphics.newImage("gfx/Interface/shield.png")
	icons["hardened"] = love.graphics.newImage("gfx/Interface/shield.png")
end

function level1()
	system = SolarSystem:new(0, 0)

	local e = nil

	system:createCenterOrbiter(
		"sun",
		"gfx/Planets/sun.png", 3,
		0, 0,
		10,
		{}
	)

	system:createCenterOrbiter(
		"planet1",
		"gfx/Planets/planet1.png", 0.9,
		800, 30,
		8,
		{"planet2", "planet3"}
	)
	e = system:getObjectByName("planet1")
	e.node = Node(0.01, 2, Node.Category.Normal)
	e.node.status.available = true
	e.node.status.hackable = true

	system:createOrbiter(
		"planet_moon",
		"gfx/Moons/moon.png", 0.3,
		"planet1", 230, 12,
		-10,
		{}
	)

	system:createCenterOrbiter(
		"planet2",
		"gfx/Planets/planet2.png", 1.1,
		1500, 40,
		5,
		{}
	)
	e = system:getObjectByName("planet2")
	e.node = Node(1, 1, Node.Category.Storage)
	e.node.status.available = true

	system:createCenterOrbiter(
		"planet3",
		"gfx/Planets/planet3.png", 1.4,
		3000, 64,
		20,
		{}
	)
	e = system:getObjectByName("planet3")
	e.node = Node(0.1, 1, Node.Category.Firewall)
	e.node.status.available = true
	e.node.status.traced = true

	-- PLAYER
	system:createCenterOrbiter(
		"player",
		"gfx/Interface/spaceship.png", 1,
		2100, -64,
		32,
		{"planet1"}
	)
	e = system:getObjectByName("player")
	--e.rot = -math.pi / 2
	e.node = Node(0.0, 0, Node.Category.Home)
	e.node.status.available = true
	e.node.status.hacked = true
	e.node.status.fortified = true
end

function level2()
	system = SolarSystem:new(0, 0)

	local e = nil

	system:createCenterOrbiter(
		"sun",
		"gfx/Planets/sun.png", 2.2,
		0, 0,
		0,
		{}
	)

	system:createCenterOrbiter(
		"planet1",
		"gfx/Planets/planet1.png", 0.9,
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
		"gfx/Moons/moon.png", 0.4,
		"planet1", 250, 8,
		-10,
		{}
	)

	system:createCenterOrbiter(
		"planet2",
		"gfx/Planets/planet2.png", 1.1,
		1200, 40,
		5,
		{"planet5"}
	)
	e = system:getObjectByName("planet2")
	e.node = Node(1, 1, Node.Category.Storage)
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
		"gfx/Moons/moon.png", 0.4,
		"planet3", 250, 4,
		3,
		{}
	)

	system:createCenterOrbiter(
		"planet4",
		"gfx/Planets/planet5.png", 1,
		2100, 52,
		12,
		{}
	)
	e = system:getObjectByName("planet4")
	e.node = Node(0.1, 1, Node.Category.Target)
	e.node.status.available = true

	system:createCenterOrbiter(
		"planet5",
		"gfx/Planets/planet6.png", 1.4,
		2600, 64,
		20,
		{}
	)
	e = system:getObjectByName("planet5")
	e.node = Node(0.1, 1, Node.Category.Firewall)
	e.node.status.available = true
	e.node.status.traced = true
	-- set start point for ai
	ai.home = e

	system:createCenterOrbiter(
		"player",
		"gfx/Interface/spaceship.png", 1,
		3000, -64,
		32,
		{"planet1"}
	)

	-- PLAYER
	e = system:getObjectByName("player")
	--e.rot = -math.pi / 2
	e.node = Node(0.0, 0, Node.Category.Home)
	e.node.status.available = true
	e.node.status.hacked = true
	e.node.status.fortified = true
end

function level3()
	system = SolarSystem:new(0, 0)

	local e = nil

	system:createCenterOrbiter(
		"sun",
		"gfx/Planets/sun.png", 3,
		0, 0,
		10,
		{}
	)

	system:createCenterOrbiter(
		"1",
		"gfx/Planets/planet5.png", 1.2,
		1200, -30,
		12,
		{"m1", "m2"}
	)
	e = system:getObjectByName("1")
	e.node = Node(0.8, 2, Node.Category.Normal)
	e.node.status.available = true
	e.node.status.hackable = true

	system:createOrbiter(
		"m1",
		"gfx/Moons/moon.png", 0.8,
		"1", 650, 34,
		-8,
		{"2"}
	)
	e = system:getObjectByName("m1")
	e.node = Node(0.8, 2, Node.Category.Storage)
	e.node.status.available = true

	system:createOrbiter(
		"m2",
		"gfx/Moons/moon.png", 0.5,
		"1", 350, 27,
		-15,
		{}
	)
	e = system:getObjectByName("m2")
	e.node = Node(0.8, 1, Node.Category.Utility)
	e.node.status.available = true

	system:createCenterOrbiter(
		"2",
		"gfx/Planets/planet4.png", 1.2,
		2200, 40,
		5,
		{"3", "f"}
	)
	e = system:getObjectByName("2")
	e.node = Node(0.8, 2, Node.Category.Storage)
	e.node.status.available = true

	system:createCenterOrbiter(
		"3",
		"gfx/Planets/planet1.png", 1.1,
		3200, 40,
		5,
		{}
	)
	e = system:getObjectByName("3")
	e.node = Node(0.8, 3, Node.Category.Target)
	e.node.status.available = true

	system:createCenterOrbiter(
		"f",
		"gfx/Planets/planet3.png", 1.4,
		4200, 80,
		30,
		{}
	)
	e = system:getObjectByName("f")
	e.node = Node(0.4, 2, Node.Category.Firewall)
	e.node.status.available = true
	e.node.status.traced = true


	-- PLAYER
	system:createCenterOrbiter(
		"player",
		"gfx/Interface/spaceship.png", 1,
		5000, -64,
		32,
		{"1"}
	)
	e = system:getObjectByName("player")
	--e.rot = -math.pi / 2
	e.node = Node(0.0, 0, Node.Category.Home)
	e.node.status.available = true
	e.node.status.hacked = true
	e.node.status.fortified = true
end

function level4()
	system = SolarSystem:new(0, 0)


	local e = nil

	system:createCenterOrbiter(
		"s1",
		"gfx/Planets/sun.png", 3,
		800, 15,
		10,
		{}
	)
	e = system:getObjectByName("s1")
	e.orbAngle = math.pi

	system:createCenterOrbiter(
		"s2",
		"gfx/Planets/sun.png", 2,
		800, 15,
		20,
		{}
	)
	e = system:getObjectByName("s2")
	e.orbAngle = 0

	system:createCenterOrbiter(
		"1",
		"gfx/Planets/planet3.png", 4,
		4200, -60,
		12,
		{"m1", "2", "m2"}
	)
	e = system:getObjectByName("1")
	e.node = Node(0.8, 2, Node.Category.Normal)
	e.node.status.available = true
	e.node.status.hackable = true

	system:createOrbiter(
		"m1",
		"gfx/Planets/planet6.png", 1,
		"1", 1050, 34,
		-8,
		{}
	)
	e = system:getObjectByName("m1")
	e.node = Node(0.6, 3, Node.Category.Utility)
	e.node.status.available = true

	system:createOrbiter(
		"m2",
		"gfx/Moons/moon.png", 0.4,
		"m1", 300, 34,
		-8,
		{}
	)
	e = system:getObjectByName("m2")
	e.node = Node(0.8, 2, Node.Category.Target)
	e.node.status.available = true

	system:createCenterOrbiter(
		"2",
		"gfx/Planets/planet1.png", 1,
		6200, -60,
		12,
		{"m3"}
	)
	e = system:getObjectByName("2")
	e.node = Node(0.8, 2, Node.Category.Target)
	e.node.status.available = true

	system:createOrbiter(
		"m3",
		"gfx/Moons/moon.png", 0.6,
		"2", 400, -18,
		8,
		{}
	)
	e = system:getObjectByName("m3")
	e.node = Node(0.8, 2, Node.Category.Firewall)
	e.node.status.available = true

	-- PLAYER
	system:createCenterOrbiter(
		"player",
		"gfx/Interface/spaceship.png", 1,
		7100, -64,
		32,
		{"1"}
	)
	e = system:getObjectByName("player")
	--e.rot = -math.pi / 2
	e.node = Node(0.0, 0, Node.Category.Home)
	e.node.status.available = true
	e.node.status.hacked = true
	e.node.status.fortified = true

	winningHandler.targetsOnMap = 2
end

currentLevel = 1

levelMap = {}
levelMap[1] = level1
levelMap[2] = level2
levelMap[3] = level3
levelMap[4] = level4

endGame = false

function level(n)
	local c = table.getn(levelMap)
	if n > c then
		endGame = true
	else
		levelMap[n]()
	end
	camera:setPosition(love.window.getWidth() / 2, love.window.getHeight() / 2)
end

--
function love.load()
	globalSetupShit()

	baseSetup()

	print("loading level "..currentLevel)
	level(currentLevel)

	if not endGame then
		system:foreach(function (self, i, v)
			v:load()
		end)
	end

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
winWait = 1.5
winAccu = 0

endAccu = 0
function love.update(dt)
	if winningHandler.state == "win" then
		--
		ai:reset()

		love.graphics.print("WIN")
		if winAccu >= winWait then
			winAccu = 0
			currentLevel = currentLevel + 1
			print("currentLevel before "..currentLevel)
			if currentLevel > table.getn(levelMap) then
				endGame = true
				winningHandler.state = "Thank you for playing!"
			else
				love.load()
			end
		else
			winAccu = winAccu + dt
		end
	elseif winningHandler.state == "fail" then
		--
		love.load()
	end

	if endGame then
		isRunnig = false
		return
	end

	if not isRunnig then
		return
	end

	eventManager:update(dt)
	camera:update(dt)
	system:update(dt)
	ai:update(system, dt)
end

function love.draw()
	local ww = love.window.getWidth()
	local wh = love.window.getHeight()

	if endGame then
		love.graphics.print(winningHandler.state)
		--love.graphics.setFont(ffont)
		--love.graphics.print("Thank you for playing!\nProgramming: Sven Freiberg\nArt: Mirko Gioa")		
		return
	end

	if winningHandler.state == "win" then
		--
		love.graphics.print("WIN", ww / 2, wh / 2)
		return
	elseif winningHandler.state == "fail" then
		--
		love.graphics.print("FAIL", ww / 2, wh / 2)
		return
	end

	local bgw = background:getWidth()
	local bgh = background:getHeight()

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

				love.graphics.setFont(ffont)

				love.graphics.print(
					v.node.hardening,
					v.x - (v.img:getWidth() / 2 + ffont:getWidth(v.node.difficulty) / 2) * v.scale,
					v.y + (v.img:getHeight() / 2 - ffont:getHeight(v.node.difficulty) / 2) * v.scale
				)

				love.graphics.print(
					v.node.difficulty,
					v.x + (v.img:getWidth() / 2) * v.scale,
					v.y + (v.img:getHeight() / 2 - ffont:getHeight(v.node.difficulty) / 2) * v.scale
				)

				if v.node.category == Node.Category.Target then
					love.graphics.setColor(255, 255, 64, 255)
				elseif v.node.category == Node.Category.Firewall then
					love.graphics.setColor(255, 0, 0, 255)
				else					
					love.graphics.setColor(0, 128, 128, 255)
				end
				love.graphics.draw(
					icons[v.node.category],					
					v.x + (v.img:getWidth() / 2 - icons[v.node.category]:getWidth() / 2) * v.scale,
					v.y - (v.img:getHeight() / 2 + icons[v.node.category]:getHeight() / 2) * v.scale,
					0,
					3, 3
				)

				love.graphics.setColor(r, g, b, a)

				if v.node.status.beingHacked or v.node.status.beingFortified then
					love.graphics.print(
						math.floor(math.abs(v.node.progress * 100)).."%",
						v.x - selector.inner:getWidth() / 2 * v.scale,
						v.y - selector.inner:getHeight() / 2 * v.scale
					)
				end

				if v.node.status.selected then
					love.graphics.draw(
						selector.outer,
						v.x, v.y, 
						0,
						v.scale, v.scale, 
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
			end)		
		love.graphics.pop()
	love.graphics.pop()

	love.graphics.setFont(dfont)
	if player.detected then
		love.graphics.setColor(255, 0, 0, 255)
		love.graphics.print("Detected!", 42, 42)
	else
		love.graphics.setColor(0, 255, 0, 255)
		love.graphics.print("Undetected.", 42, 42)
	end

	if ai.active then
		love.graphics.setColor(255, 0, 0, 255)
		local timeLeft = round(ai.time.value - ai.time.passed, 2)
		love.graphics.print(timeLeft, 42, 128)
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
	if key == " " and not endGame then
		isRunnig = not isRunnig
	end
	if key == "f1" then
		local fs = love.window.getFullscreen()
		love.window.setFullscreen(not fs)
	end
end
