local mqtt = require("mqtt_library")
local settings = require("settings")
local player_settings = settings[settings.player].love

function love.load ()
	-- (DEBUG) activate print
	io.stdout:setvbuf("no")
	
	-- requiring files
	require('lua/screen')
	require('lua/statusscreen')

	-- screen startup
	screen_size = 600
	status_size = 150
	love.window.setMode(screen_size,screen_size+status_size)
	love.window.setTitle("Jogo da Imitação")
	love.graphics.setBackgroundColor(0.1,0.1,0.1)

	local starting_turn = settings[settings.player].starting_turn

	screen = createScreen(screen_size, screen_size)
	status_screen = createStatusScreen(0, screen_size, screen_size, status_size, starting_turn)
	
	-- sons
	local src1 = love.audio.newSource("sounds/220.ogg","static")
	local src2 = love.audio.newSource("sounds/262.ogg","static")
	local src3 = love.audio.newSource("sounds/330.ogg","static")
	local src4 = love.audio.newSource("sounds/392.ogg","static")
	
	screen:add_sounds(src1, src2, src3, src4)
	
	--[[
	-- exemplos tocando sequencia, acerto, erro
	screen:draw_sequence("13242")
	screen:button_press('1',0,1,0)
	screen:button_press('4',1,0,0)
	]]--

	-- conexão mqtt
	mqtt_client = mqtt.client.create(settings.internet.server, settings.internet.port, mqttcb)
	mqtt_client:connect(player_settings.id)
	mqtt_client:subscribe(player_settings.node_queue)
end

-- recebe mensagens mqtt
function mqttcb(topic, message)
	print("MENSAGEM RECEBIDA: "..topic)
	print("mensagem: "..message)
	
	local character = message:sub(1, 1)
	print("character: "..character)
	
	if character == 's' then
		local sequence = message:sub(2,#message)
		print("printing sequence "..sequence)
		screen:draw_sequence(sequence)
		status_screen:set_status(1)
		
	elseif character == 'h' then
		local button = message:sub(2,#message)
		print("printing hit "..button)
		screen:button_press(button,0,1,0)
		
	elseif character == 'e' then
		local button = message:sub(2,#message)
		print("printing miss "..button)
		screen:button_press(button,1,0,0)
		status_screen:set_status(4)
		
	elseif character == 'v' then
		print("vitoria")
		status_screen:set_status(3)
		
	elseif character == 'f' then
		local button = message:sub(2,#message)
		print("printing end sequence "..button)
		screen:button_press(button,0.9,0.9,0.9)
		status_screen:set_status(2)
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
	status_screen:draw()
end

function love.quit()
	os.exit()
end
