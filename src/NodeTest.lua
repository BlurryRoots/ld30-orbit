


Node = {}
function Node:new(x, y, t)
	local nobj = {
		x = 0,
		y = 0,
		ntype = t or "standard",
		children = {}
	}

	nobj.link = function(self, child)
		table.insert(self.children, child)
	end

	nobj.nchild = function(self, n)
		return self.children[n]
	end

	nobj.count = function(self)
		return table.getn(self.children)
	end

	nobj.render = function(self)

	end

	return nobj
end

local root = nil
function love.load()
	root = {
		x = 100, y = 100,
		ch = {
			{
				x = 200, y = 250,
				ch = {}
			},
			{
				x = 180, y = 400,
				ch = {
					{
						x = 400, y = 100,
						ch = {}
					}
				}
			}
		}
	}
end

function render(node)
	local n = table.getn(node.ch)
	if n == 0 then
		return false
	end

	for i,v in ipairs(node.ch) do
		love.graphics.line(node.x, node.y, v.x, v.y)
		render(v)
	end

	return true
end

function love.update(dt)
end

function love.draw()
	render(root)
end

function love.mousepressed(x, y, button)
end
