local mqtt = require("mqtt_library")
local settings = require("settings")
local json = require("json/json")
local player_settings = settings[settings.player].love

-- controla de quem é a vez
local turn = settings[settings.player].starting_turn

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
  mqtt_client:subscribe(player_settings.subscribe)
end

-- função para mandar jogada para computador oponente
function faz_jogada(msg)
  print("mandando jogada")
  mqtt_client:publish(player_settings.attack_queue,msg,0,0, 
            function(client) print("mandou jogada") end)
end

-- função para mandar resposta de jogada para computador oponente
function manda_resposta(msg)
  print("mandando resposta da jogada")
  mqtt_client:publish(player_settings.response_queue,msg,0,0, 
            function(client) print("mandou resposta da jogada") end)
end

-- quando recebe jogada inimiga
function opponent_play(message)
  print("queue response da play")
end

-- processa a resposta de uma play, se acertou ou não
function check_play(message)
  print("queue response check play message")
  print(message)
end


function nodemcu_keyboard(node_message)
  print("sequence received from nodemcu " .. node_message)

  local sequence = {}
  node_message:gsub(".",function(character) table.insert(sequence, tonumber(character)) end)

  screen:draw_sequence(sequence)
end

-- recebe mensagens mqtt
function mqttcb(topic, message)
  print("MENSAGEM RECEBIDA: "..topic)
  
  -- mensagem é na fila de jogada inimiga
  if (topic == player_settings.subscribe[1]) then
    opponent_play(message)
  
  -- mensagem é na fila do nodemcu = é entrada de teclado
  elseif (topic == player_settings.subscribe[2]) then
    nodemcu_keyboard(message)
    
  -- mensagem é na fila de resposta da jogada
  elseif (topic == player_settings.subscribe[3]) then
    check_play(message)
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
