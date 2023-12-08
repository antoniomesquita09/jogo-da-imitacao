settings = {
  -- which player is active
  -- to play multiplayer, one of the programs have to use 'player1' and the other 'player2'
  player = "player1",
  
  -- internet connection settings
  internet = {
    id = "Felipe e Katia",
    password = "fk123456",
    server="139.82.100.100",
    port=7981
  },

  -- player 1 ids and queues
  player1 = {
    starting_turn = 1, -- player 1 plays first
    
    node = {
      id = "node_jogo_da_imitacao_1",
      subscribe = "node_jogo_da_imitacao_1",
      publish_node = "node_jogo_da_imitacao_2",
      publish_love = "love_jogo_da_imitacao_1"
    },
    
    love = {
      id = "jogo_da_imitacao_1",
      node_queue = "love_jogo_da_imitacao_1",
    }
  },
  
  -- player 2 ids and queues
  player2 = {
    starting_turn = 2, -- player 2 waits first
    
    node = {
      id = "node_jogo_da_imitacao_2",
      subscribe = "node_jogo_da_imitacao_2",
      publish_node = "node_jogo_da_imitacao_1",
      publish_love = "love_jogo_da_imitacao_2"
    },
    
    love = {
      id = "jogo_da_imitacao_2",
      node_queue = "love_jogo_da_imitacao_2",

    }
  }
}

return(settings)
