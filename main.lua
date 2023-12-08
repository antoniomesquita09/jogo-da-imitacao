local mqtt = require("mqtt_library")
local settings = require("settings")
local json = require("json/json")
local player_settings = settings[settings.player].love

function love.load ()
  -- (DEBUG) activate print
  io.stdout:setvbuf("no")
  
  -- requiring files
  require('lua/screen')

  -- screen startup
  screen_size = 1000
  love.window.setMode(screen_size,screen_size)
  love.window.setTitle("Jogo da Imitação")
  love.graphics.setBackgroundColor(0.5,0.5,0.5)

  screen = createScreen(screen_size, screen_size)
  
  -- exemplo de sequência sendo desenhada
  -- screen:draw_sequence({1,3,2,2,4,1})

  -- conexão mqtt
  mqtt_client = mqtt.client.create(settings.internet.server, settings.internet.port, mqttcb)
  mqtt_client:connect(player_settings.id)
  mqtt_client:subscribe(player_settings.node_queue)
end

-- recebe mensagens mqtt
function mqttcb(topic, message)
  print("MENSAGEM RECEBIDA: "..topic)
  print("mensagem: "..message)
  
  caracter = string.sub(message, 1, 1)
  print("character: "..caracter)
  
  if caracter == 's' then
    sequence = string.sub(message, 2,#message)
    print("printing sequence "..sequence)
    screen:draw_sequence(sequence)
    
  elseif caracter == 'h' then
    button = string.sub(message, 2,#message)
    print("printing hit "..button)
    screen:button_press(button,0,1,0)
    
  elseif caracter == 'e' then
    button = string.sub(message, 2,#message)
    print("printing miss "..button)
    screen:button_press(button,1,0,0)
    
  elseif caracter == 'v' then
    print("vitoria")
    
  elseif caracter == 'f' then
    button = string.sub(message, 2,#message)
    print("printing end sequence "..button)
    screen:button_press(button,0.9,0.9,0.9)
    
  end
  
end

function love.update(dt)
  -- tem que chamar o handler aqui!
  screen:update(dt)
  mqtt_client:handler()
end

function love.draw()
  -- desenhar tela
  screen:draw()
end

function love.quit()
  os.exit()
end
