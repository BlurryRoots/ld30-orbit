function love.load()
end

accu = 0
thresh = 1
val = 0
function love.update(dt)
	if accu > thresh then
		val = love.math.random(math.pi * 2)
		accu = 0
	else
		accu = accu + dt
	end
end

function love.draw()
	love.graphics.print(val, 128, 128)
end

function love.mousepressed(x, y, button)
end