-- 'classe' da tela (recebe largura e altura)
function createScreen(width, height)
    
    return {
      -- tamanho do tabuleiro (quantos quadrados e tamanho em pixels)
      width = width,
      height = height,
      
      -- lista para animação
      -- um botão é iluminado de cada vez
      drawing_queue={},

      -- botão do node apertado (ilumina quadrado apertado)
      -- botão = número de 1 a 4 (equivalente a botão apertado)
      -- botões ficam desenhados por 1 segundo
      button_press = function(self, btn, red, green, blue)
        local button_dict = {
          drawcode=btn,
          r=red,
          g=green,
          b=blue,
          time=1
        }
        table.insert(self.drawing_queue,button_dict)
      end,

      -- adiciona sequência de botões a ser desenhada
      -- botões ficam desenhados por 1 segundo, com intervalos de 0.5 segundos
      draw_sequence = function(self, button_sequence)
        for i,btn in ipairs(button_sequence) do
          button_dict = {
            drawcode=btn,
            r=0.9,
            g=0.9,
            b=0.9,
            time=1
          }
          rest_dict = {
            drawcode=0,
            r=0,
            g=0,
            b=0,
            time=0.5
          }
          table.insert(self.drawing_queue,button_dict)
          table.insert(self.drawing_queue,rest_dict)
        end
      end,

      update = function(self, dt)
        -- atualiza botões pra animação
        if (#self.drawing_queue > 0) then
          -- tira tempo da animação, se tiver passado tira da fila
          self.drawing_queue[1].time = self.drawing_queue[1].time - dt
          if (self.drawing_queue[1].time <= 0) then
            table.remove(self.drawing_queue,1)
          end
        end
      end,
      
      draw = function(self)
        -- animação botão
        if (#self.drawing_queue > 0) then
          button_to_draw = self.drawing_queue[1]
          love.graphics.setColor(button_to_draw.r,button_to_draw.g,button_to_draw.b)

          if (button_to_draw.drawcode == 1) then love.graphics.rectangle("fill", 0, 0, width/2, height/2) end
          if (button_to_draw.drawcode == 2) then love.graphics.rectangle("fill", width/2, 0, width/2, height/2) end
          if (button_to_draw.drawcode == 3) then love.graphics.rectangle("fill", 0, height/2, width/2, height/2) end
          if (button_to_draw.drawcode == 4) then love.graphics.rectangle("fill", width/2, height/2, width/2, height/2) end
        end

        -- contornos
        love.graphics.setColor(0.2,0.2,0.2)
        love.graphics.rectangle("line", 0, 0, width/2, height/2)
        love.graphics.rectangle("line", width/2, 0, width/2, height/2)
        love.graphics.rectangle("line", 0, height/2, width/2, height/2)
        love.graphics.rectangle("line", width/2, height/2, width/2, height/2)
      end
    }
  end