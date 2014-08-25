require("lib.lclass")

class "Node"

function Node:Node(chance, difficulty)
	self.status = {
		available = false,
		hackable = false,
		selected = false,
		beingHacked = false,
		hacked = false,
		fortified = false
	}
	
	self.detectionChance = chance
	self.difficulty = difficulty

	self.accu = 0
end

function Node:unselect()
	self.status.selected = false
end
function Node:select()
	self.status.selected = true
end
function Node:toggleSelect()
	self.status.selected = not self.status.selected
end

function Node:hack()
	if self.status.hackable and not self.status.hacked then
		self.status.beingHacked = true
		print("commencing hack")
	end
end

function Node:fortify()
	if self.status.hacked and not self.status.fortified then
		self.status.beingFortified = true
		print("commencing fortification")
	end
end

function Node:update(dt)
	if self.status.beingHacked then
		if self.accu >= self.difficulty then
			self.status.beingHacked = false
			self.status.hacked = true
			self.accu = 0

			return
		end

		self.accu = self.accu + dt

		local r = love.math.random()

		if r < self.detectionChance then
			print("detected while hacking")
		end
	elseif self.status.beingFortified then
		if self.accu >= self.difficulty then
			self.status.beingFortified = false
			self.status.fortified = true
			self.accu = 0

			return
		end

		self.accu = self.accu + dt

		local r = love.math.random()

		if r < self.detectionChance then
			print("detected while fortifying")
		end
	end

	
end

function Node:render(camera)
end
