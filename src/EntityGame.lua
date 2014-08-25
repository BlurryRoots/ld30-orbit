require("lib.ecs.Entity")
require("lib.ecs.PositionComponent")
require("lib.ecs.RotationComponent")
require("lib.ecs.OrbitComponent")
require("lib.ecs.PlanetComponent")

require("src.RenderPlanetSystem")

require("src.Camera")

local database = {}
local assetManager = {
	images = {},
	load = function(self, path)
		self.images[path] = love.graphics.newImage(path)
	end,	
	get = function(self, path)
		return self.images[path]
	end,
}

local rs = nil


--[[
	CONCENTRATE ON GAME MECHANICS !!!
		Create Graph
		Node Types
			Standard
			Entry
			Bonus
			Target
			Enemy
		Every Node has a specific Risk of alerting the Enemy
		Create workable Interface
]]


function love.load()
	assetManager:load("gfx/256x256/Planets/planet1.png")
	assetManager:load("gfx/256x256/Planets/planet2.png")

	rs = RenderPlanetSystem(assetManager)

	local e = nil

	e = Entity()
	e:addComponent(PositionComponent(100, 21))
	e:addComponent(RotationComponent(1000))
	e:addComponent(PlanetComponent("gfx/256x256/Planets/planet1.png"))
	table.insert(database, e)

	e = Entity()
	e:addComponent(PositionComponent(42, 300))
	e:addComponent(PlanetComponent("gfx/256x256/Planets/planet2.png"))
	e:addComponent(RotationComponent(500))
	table.insert(database, e)
end

function love.update(dt)
	camera:update(dt)
end

function love.draw()
	rs:render(database, camera)
end

function love.mousepressed(x, y, button)
	camera:onMouseButtonDown(button)
end
