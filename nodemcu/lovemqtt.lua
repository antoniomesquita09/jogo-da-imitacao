-- settings
local settings = require("settings")
node_settings = settings[settings.player].node
love_settings = settings[settings.player].love

local chave = 0
local delay = 200000
local last = 0
local sw1 = 3
local sw2 = 4
local sw3 = 5
local sw4 = 8

turn = settings[settings.player].starting_turn

-- 1, 2, 3, 4 = A, C, E, G 
tones = {220,262,330,392}

buzzerPin = 7
gpio.mode(buzzerPin, gpio.OUTPUT)

gpio.mode(sw1,gpio.INT,gpio.PULLUP)
gpio.mode(sw2,gpio.INT,gpio.PULLUP)
gpio.mode(sw3,gpio.INT,gpio.PULLUP)
gpio.mode(sw4,gpio.INT,gpio.PULLUP)

local meuid = node_settings.id
local m = mqtt.Client(meuid, 120)

play_success = 'SUCCESS'
play_failure = 'FAILURE'
sequence = ""


function check_sequence(button)
       position = 1
       updated_button = button
       while true do 
            if sequence:sub(position,position) == updated_button then
                position = position + 1
                updated_button = coroutine.yield(1) --acertou botao da sequencia
            elseif position == #sequence+1 then
                position = 1
                sequence = sequence .. updated_button --incrementa sequencia
                updated_button = coroutine.yield(3) --acabou sequencia
            else 
                position = 1
                updated_button = coroutine.yield(2) -- errou botao da sequencia
            end
            
       end
end
      
function beep(pin, tone, duration)
    local freq = tone
    print ("Frequency:" .. freq)
    pwm.setup(pin, freq, 512)
    pwm.start(pin)
    -- delay in uSeconds
    tmr.delay(duration * 1000)
    pwm.stop(pin)
    --20ms pause
    tmr.wdclr()
    tmr.delay(20000)
end

function buzz_sequence(sequence_string)
    button_sequence = {}
    for i = 1, #sequence_string do
        button_sequence[i] = tonumber(sequence_string:sub(i, i))
    end

    for i,btn in ipairs(button_sequence) do
        beep(buzzerPin, tones[tonumber(button)], 1000)
        tmr.delay(500 * 1000)
    end
end

function publish_love(c,msg)
  print("mandando pro love")
  print(msg)
  c:publish(node_settings.publish_love,msg,0,0, 
            function(client) print("mandou pro love! "..msg) end)
end

function publish_node(c,msg)
  print("mandando pro node")
  print(msg)
  c:publish(node_settings.publish_node,msg,0,0, 
            function(client) print("mandou pro node! "..msg) end)
end

function nodeSubscription(client)
  local msgsrec = 0
  function novamsg(c, t, m)
    if t ~= node_settings.subscribe then return end
    print ("mensagem node ".. msgsrec .. ", topico: ".. t .. ", dados: " .. m)

    if m == '0' then 
        turn = 3 --venceu
        publish_love(client, 'v')
    else
        sequence = m
        publish_love(client, 's'..sequence)
        buzz_sequence(sequence)
        turn = 1 --nossa vez
    end

    msgsrec = msgsrec + 1
  end
  client:on("message", novamsg)
end

function conectado(client)
  client:subscribe(node_settings.subscribe, 0, nodeSubscription)
 
  co = coroutine.create(check_sequence)

  function button_pressed(button)
    print("pressed "..button)
    beep(buzzerPin, tones[tonumber(button)], 100)
        _, status = coroutine.resume(co,button)
        print("current status = "..status)
        if status == 1 then 
            publish_love(client,'h'..button) -- acertou botao sequencia
        elseif status == 2 then
            publish_love(client,'e'..button) -- errou botao da sequencia
            publish_node(client,'0') -- errou botao da sequencia
            turn = 4 -- perdeu
        else
            publish_love(client,'f'..button) -- acabou sequencia 
            publish_node(client,sequence) --manda pro outro node a seq
            turn = 2 --passa a vez
        end
  end
  
  gpio.trig(sw1, "down", 
    function (level,timestamp)
        if turn ~= 1 then return end
        if timestamp - last < delay then return end
        last = timestamp

        button_pressed('1')
    end)
    
  gpio.trig(sw2, "down", 
    function (level,timestamp)
        if turn ~= 1 then return end
        if timestamp - last < delay then return end
        last = timestamp

        button_pressed('2')
    end)
    
  gpio.trig(sw3, "down", 
    function (level,timestamp)
        if turn ~= 1 then return end
        if timestamp - last < delay then return end
        last = timestamp

        button_pressed('3')
    end)
    
  gpio.trig(sw4, "down", 
    function (level,timestamp)
        if turn ~= 1 then return end
        if timestamp - last < delay then return end
        last = timestamp

        button_pressed('4')
    end)
end 

m:connect(settings.internet.server, settings.internet.port, false, 
             conectado,
             function(client, reason) print("failed reason: "..reason) end)
