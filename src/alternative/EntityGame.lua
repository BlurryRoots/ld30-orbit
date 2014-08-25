require("lib.ecs.Entity")
require("lib.ecs.Database")


require("src.alternative.components.PositionComponent")
require("src.alternative.components.RotationComponent")
require("src.alternative.components.OrbitComponent")
require("src.alternative.components.PlanetComponent")

require("src.alternative.RenderPlanetSystem")
require("src.alternative.SpaceObjectInputSystem")

require("src.Camera")

local database = nil
local assetManager = {
	images = {},
	load = function(self, path)
		self.images[path] = love.graphics.newImage(path)
	end,	
	get = function(self, path)
		return self.images[path]
	end
}
local eventManager = {
}

local rs = nil
local us = nil


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
	database = Database()

	assetManager:load("gfx/256x256/Planets/planet1.png")
	assetManager:load("gfx/256x256/Planets/planet2.png")

	rs = RenderPlanetSystem(assetManager)
	us = SpaceObjectInputSystem(assetManager)

	local e = nil

	e = Entity()
	e:addComponent(PositionComponent(100, 21))
	e:addComponent(RotationComponent(1000))
	e:addComponent(PlanetComponent("gfx/256x256/Planets/planet1.png"))
	database:add(e)

	e = Entity()
	e:addComponent(PositionComponent(42, 300))
	e:addComponent(PlanetComponent("gfx/256x256/Planets/planet2.png"))
	e:addComponent(RotationComponent(500))
	database:add(e)
end

function love.update(dt)
	camera:update(dt)
	us:onUpdate(database, camera, dt)
end

function love.draw()
	rs:render(database, camera)
end

function love.mousepressed(x, y, button)
	camera:onMouseButtonDown(button)
	us:mousepressed(x, y, button)
end
