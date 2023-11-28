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
end


function nodemcu_keyboard(node_message)
  -- não tá na sua vez = não faz nada
  print("queue node mcu keyboard message")
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
  mqtt_client:handler()
end

function love.draw ()
  -- desenhar tabuleiro
end

function love.quit()
  os.exit()
end
