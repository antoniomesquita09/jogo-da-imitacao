settings = {
  -- which player is active
  -- to play multiplayer, one of the programs have to use 'player1' and the other 'player2'
  player = "player1",
  
  -- internet connection settings
  internet = {
    id = "wifi-id",
    password = "wifi-password",
    server="139.82.100.100",
    port=7981
  },

  -- player 1 ids and queues
  player1 = {
    starting_turn = 1, -- player 1 plays first
    
    node = {
      id = "node_jogo_da_imitacao_1",
      subscribe = "love_jogo_da_imitacao_1",
      publish = "node_jogo_da_imitacao_1"
    },
    
    love = {
      id = "jogo_da_imitacao_1",
      subscribe = {"jogo_da_imitacao_2", "node_jogo_da_imitacao_1", "response_jogo_da_imitacao_1"}, -- fila de receber jogada, de receber comando e de receber resposta de jogada
      node_queue = "love_jogo_da_imitacao_1",
      attack_queue = "jogo_da_imitacao_1",
      response_queue = "response_jogo_da_imitacao_2"
    }
  },
  
  -- player 2 ids and queues
  player2 = {
    starting_turn = 2, -- player 2 waits first
    
    node = {
      id = "node_jogo_da_imitacao_2",
      subscribe = "love_jogo_da_imitacao_2",
      publish = "node_jogo_da_imitacao_2"
    },
    
    love = {
      id = "jogo_da_imitacao_2",
      subscribe = {"jogo_da_imitacao_1", "node_jogo_da_imitacao_2", "response_jogo_da_imitacao_2"}, -- fila de receber jogada, de receber comando e de receber resposta de jogada
      node_queue = "love_jogo_da_imitacao_2",
      attack_queue = "jogo_da_imitacao_2",
      response_queue = "response_jogo_da_imitacao_1"
    }
  }
}

return(settings)
