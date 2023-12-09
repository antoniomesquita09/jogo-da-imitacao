-- 'classe' da tela (recebe largura e altura)
function createStatusScreen(x, y, width, height, initial_status)
	local status_colors = {
		{0.4,0.4,0.8},
		{0.5,0.5,0.5},
		{0.6,0.9,0.6},
		{0.6,0.2,0.2},
	}

	local font = love.graphics.newFont(28)
	love.graphics.setFont(font)

  	return {
		-- posição e tamanho dos stats
		x = x,
		y = y,
		width = width,
		height = height,

		status = initial_status,

		set_status = function(self, new_status)
			self.status = new_status
		end,

		update = function(self, dt)
		end,
		
		draw = function(self)
			-- fundo
			color = status_colors[self.status]
			love.graphics.setColor(color[1],color[2],color[3])
			love.graphics.rectangle("fill", x, y, width, height)

			-- texto status
			love.graphics.setColor(1, 1, 1)
			if (self.status == 1) then
				love.graphics.printf("SUA VEZ", 0, y+height/4, width, "center")
				love.graphics.printf("FAÇA A SEQUÊNCIA", 0, y+2*height/4, width, "center")
			elseif (self.status == 2) then
				love.graphics.printf("VEZ DO OPONENTE", 0, y+height/4, width, "center")
				love.graphics.printf("AGUARDE A SEQUÊNCIA", 0, y+2*height/4, width, "center")
			elseif (self.status == 3) then
				love.graphics.printf("VITÓRIA", 0, y+height/4, width, "center")
				love.graphics.printf("SEU OPONENTE ERROU", 0, y+2*height/4, width, "center")
			elseif (self.status == 4) then
				love.graphics.printf("DERROTA", 0, y+height/4, width, "center")
				love.graphics.printf("VOCÊ ERROU", 0, y+2*height/4, width, "center")
			end
		end
	}
end
