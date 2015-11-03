defmodule Game.Acceptor do
  require Logger
  alias Game.PlayerPosition
  alias Game.Board
  
  def start(socket) do
    Logger.debug fn -> "in Acceptor with socket #{inspect socket}" end
    intro(socket) |> loop
  end

  defp greeting do
    "Welcome to the adventure game!\r\n\r\n"
  end

  defp intro(socket) do
    :gen_tcp.send(socket, greeting)
    :gen_tcp.send(socket, "player name: ")
    {:ok, data} = :gen_tcp.recv(socket, 0)
    Logger.debug fn -> "#{inspect __MODULE__} got #{inspect data}" end
    player_name = String.strip(data)
    case PlayerPosition.new_player(player_name) do
      :ok -> :ok
      {:error, :duplicate_player} ->
        :gen_tcp.send(socket, "Welcome back #{inspect player_name}\r\n")
        :ok
    end
    {player_name, socket}
  end

  defp loop({player_name, socket}) do
    {:ok, position} = PlayerPosition.position(player_name)
    {:ok, room_text} = Board.room(position)
    :gen_tcp.send(socket, "#{room_text}\r\n")
    :gen_tcp.send(socket, "\r\n")
    :gen_tcp.send(socket, "direction? :")
    {:ok, data} = :gen_tcp.recv(socket, 0)
    case String.strip(data) do
      "north" -> 
        PlayerPosition.move_player(player_name, :north)
        loop({player_name, socket})
      "south" -> 
        PlayerPosition.move_player(player_name, :south)
        loop({player_name, socket})
      "east" -> 
        PlayerPosition.move_player(player_name, :east)
        loop({player_name, socket})
      "west" -> 
        PlayerPosition.move_player(player_name, :west)
        loop({player_name, socket})
      "quit" -> :gen_tcp.send(socket, "goodbye\r\n")
      cmd ->
        Logger.debug fn -> "Did not match #{inspect cmd}" end
        loop({player_name, socket})
    end
  end

end
