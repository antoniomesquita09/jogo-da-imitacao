-- settings
local settings = require("settings")
local node_settings = settings[settings.player].node
local love_settings = settings[settings.player].love

local chave = 0
local delay = 200000
local last = 0
local sw1 = 3
local sw2 = 4
local sw3 = 5
local sw4 = 8

gpio.mode(sw1,gpio.INT,gpio.PULLUP)
gpio.mode(sw2,gpio.INT,gpio.PULLUP)
gpio.mode(sw3,gpio.INT,gpio.PULLUP)
gpio.mode(sw4,gpio.INT,gpio.PULLUP)

frequency_mapper = {100, 200, 300, 400}

local meuid = node_settings.id
local m = mqtt.Client(meuid, 120)

sequency_length = 1
play_success = 'SUCCESS'
play_failure = 'FAILURE'
sequence = ""

function publish(c,chave)
  c:publish(node_settings.publish,chave,0,0, 
            function(client) print("mandou! "..chave) end)
end

function nodeSubscription(c)
  local msgsrec = 0
  function novamsg(c, t, m)
    print ("mensagem node ".. msgsrec .. ", topico: ".. t .. ", dados: " .. m)

    -- for _, value in pairs(node_response.sequence) do
    --   frequency = frequency_mapper[value]
    --   -- disparar buzzer do nodemcu com a frequency 
    -- end

    msgsrec = msgsrec + 1
  end
  c:on("message", novamsg)
end

function responseSubscription(c)
  local msgsrec = 0
  function novamsg(c, t, m)
    print ("mensagem response ".. msgsrec .. ", topico: ".. t .. ", dados: " .. m)

    if m == play_success then
      -- turn on green light
      print()
    elseif m == play_failure then
      -- turn on red light
    else
      print("UNKNOWN response status")
    end

    msgsrec = msgsrec + 1
  end
  c:on("message", novamsg)
end

function conectado(client)
  client:subscribe(node_settings.subscribe, 0, nodeSubscription)
  client:subscribe(love_settings.response_queue, 0, responseSubscription)

  gpio.trig(sw1, "down", 
    function (level,timestamp)
        if timestamp - last < delay then return end
        last = timestamp
        sequence = sequence .. "1"
        print(sequence)
        if #sequence == sequency_length then
          publish(client,sequence)
          sequency_length = #sequence + 1 -- incrementa o tamanho da play com o tamanho atual + 1 da próxima jogada
          sequence = ""
        end
    end)
  gpio.trig(sw2, "down", 
    function (level,timestamp)
        if timestamp - last < delay then return end
        last = timestamp
        sequence = sequence .. "2"
        print(sequence)
        if #sequence == sequency_length then
          publish(client,sequence)
          sequency_length = #sequence + 1 -- incrementa o tamanho da play com o tamanho atual + 1 da próxima jogada
          sequence = ""
        end
    end)
  gpio.trig(sw3, "down", 
    function (level,timestamp)
        if timestamp - last < delay then return end
        last = timestamp
        sequence = sequence .. "3"
        print(sequence)
        if #sequence == sequency_length then
          publish(client,sequence)
          sequency_length = #sequence + 1 -- incrementa o tamanho da play com o tamanho atual + 1 da próxima jogada
          sequence = ""
        end
    end)
  gpio.trig(sw4, "down", 
    function (level,timestamp)
        if timestamp - last < delay then return end
        last = timestamp
        sequence = sequence .. "4"
        print(sequence)
        if #sequence == sequency_length then
          publish(client,sequence)
          sequency_length = #sequence + 1 -- incrementa o tamanho da play com o tamanho atual + 1 da próxima jogada
          sequence = ""
        end
    end)
end 

m:connect(settings.internet.server, settings.internet.port, false, 
             conectado,
             function(client, reason) print("failed reason: "..reason) end)
