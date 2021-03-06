require("lib.lclass")

class "Node"

Node.Category = {
	Home = "Home",
	Normal = "Normal",
	Utility = "Utility",
	Storage = "Storage",
	Target = "Target",
	Firewall = "Firewall"
}

function Node:Node(chance, difficulty, category)
	self.status = {
		available = false,
		hackable = false,
		selected = false,
		beingHacked = false,
		hacked = false,
		beingFortified = false,
		fortified = false,
		beingTraced = false,
		traced = false
	}
	
	self.detectionChance = chance
	self.difficulty = difficulty
	self.hardening = difficulty

	self.category = category

	self.accu = 0
	self.progress = 0

	self.aiaccu = 0
	self.aiprogress = 0
end

-- function used by ai
function Node:trace()
	print("checking")
	if not self.status.beingTraced and not self.status.traced then
		self.status.beingTraced = true
		eventManager:push({
			typeName = "trace.started"
		})
	end
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
		eventManager:push({
			typeName = "hack.started"
		})
	end
end

function Node:fortify()
	if self.status.hacked and not self.status.fortified then
		self.status.beingFortified = true
		eventManager:push({
			typeName = "fortify.started"
		})
	end
end

function Node:update(dt)
	if self.status.beingHacked then
		if self.accu >= self.difficulty then
			-- reset stuff
			self.status.beingHacked = false
			self.status.hacked = true
			self.accu = 0
			self.progress = 0

			-- roll dice to determine if you're caught
			local r = love.math.random()
			if r < self.detectionChance then
				eventManager:push({
					typeName = "player.detected"
				})
			end

			-- send finish event
			eventManager:push({
				typeName = "hack.finished",
				node = self
			})
		else
			self.progress = self.accu / self.difficulty
			self.accu = self.accu + dt
		end
	elseif self.status.beingFortified then
		if self.accu >= self.difficulty then
			-- reset stuff
			self.status.beingFortified = false
			self.status.fortified = true
			self.hardening = self.hardening + 1
			self.accu = 0
			self.progress = 0

			-- roll dice to determine if you're caught
			local r = love.math.random()
			if r < self.detectionChance then
				eventManager:push({
					typeName = "player.detected"
				})
			end

			-- send finish event
			eventManager:push({
				typeName = "fortify.finished"
			})
		else
			self.progress = self.accu / self.difficulty
			self.accu = self.accu + dt
		end
	end

	if self.status.beingTraced then
		print("tracing..")
		if self.aiaccu >= self.hardening then
			-- reset stuff
			self.status.beingTraced = false
			self.status.traced = true
			self.aiaccu = 0
			self.aiprogress = 0

			-- send finish event
			eventManager:push({
				typeName = "trace.finished"
			})
		else
			self.aiprogress = self.aiaccu / self.hardening
			self.aiaccu = self.aiaccu + dt
		end
	end	
end

function Node:render(camera)
end
