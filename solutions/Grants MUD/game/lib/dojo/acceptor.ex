defmodule Game.Acceptor do
  require Logger
  alias Game.Player, as: Player
  alias Game.Board, as: Board
  
  @newline "\r\n"
  @double_newline "\r\n\r\n"
 
  def start(socket) do
    intro(socket) |> loop
  end

  defp greeting do
    IO.ANSI.cyan <> "Welcome to Leeds Code Dojo! The Forest of Doom awaits..." <> @double_newline <> IO.ANSI.default_color
  end

  defp intro(socket) do
    :gen_tcp.send(socket, greeting())
    :gen_tcp.send(socket, "player name: ")

    {:ok, data} = :gen_tcp.recv(socket, 0)
    Logger.debug fn -> "#{__MODULE__} received data: #{inspect data}" end

    player_name = String.strip(data)
    Logger.debug fn -> "#{__MODULE__} player name: #{inspect player_name}" end

    case Player.register(player_name) do
      {:player, {name, _, _, _}} -> :gen_tcp.send(socket, "I see you have returned, #{name}.  You poor fool!" <> @double_newline)
      {:new_player, {name, _, _, _}} -> :gen_tcp.send(socket, "Welcome, brave #{name}!  You will not survive this day.." <> @double_newline)
    end

    {player_name, socket}
  end
  
  defp list_to_string(list) do
    list |> Enum.join @newline
  end
  
  defp get_name({name, _, _, _}) do 
    name
  end
  
  defp list_text(list, text) do
    @newline <> text <> @newline <> list_to_string(list) <> @double_newline
  end
  
  defp list_or_nothing(list, nothing_text, something_text) do
    case list |> length do
      0 -> @newline <> nothing_text <> @double_newline
      _ -> list |> list_text(something_text)
    end
  end
  
  defp display_other_players(player_name, position, socket) do
    other_players = Player.at(position) |> Enum.map(&get_name/1) |> Enum.reject(&(&1 == player_name))
    :gen_tcp.send(socket, other_players |> list_or_nothing("You are completely alone, your dark thoughts slowly overcoming you.", "You are surrounded by the following low-lives:"))
  end
  
  defp display_bag_contents(player_name, socket) do
    {:ok, bag_contents} = Player.bag(player_name)
    :gen_tcp.send(socket, bag_contents |> list_or_nothing("Your bag is completely empty, peasant!", "You have somehow managed to scavenge:"))
  end
  
  defp display_items(items, socket) do
    :gen_tcp.send(socket, items |> list_or_nothing( "This pitiful place has nothing of interest!", "You root around in the dirt, and eventually uncover:"))
  end
  
  defp try_take(player_name, items, item, socket) do
    case items |> Enum.member? String.to_atom(item) do
      true -> 
        Player.add_to_bag(player_name, item)
        :gen_tcp.send(socket, "You picked up #{item}.  Good for you." <> @double_newline)
      false ->
        :gen_tcp.send(socket, "There is no #{item} in the room, fool!" <> @double_newline)
    end
  end
  
  defp get_random_status() do
    ["A chill wind blows from the East.",
     "The putrid scent of rotting flesh drifts across your nostrils.",
     "A dead rat lies half-eaten on the ground.",
     "The tombstones of the recent dead are scattered all around.",
     "You don't know why, but something inside tells you to leave this place and never return.",
     "Vultures circle overhead, waiting to feast on your soon-to-be rotting carcass.",
     "A storm gathers in the distance.",
     "Rain starts to fall.",
     "A clap of thunder rumbles behind you.",
     "The bone of a previous forest wanderer cracks beneath your feet.",
     "Drops of blood spatter the surrounding foliage.",
     "An unfamiliar screech echoes in the distance, seemingly heading towards you."]
     |> Enum.random
  end
  
  defp loop({player_name, socket}) do

    {:ok, position} = Player.position(player_name)
    {:ok, {room_text, items}} = Board.room(position)
    
    :gen_tcp.send(socket, "#{room_text}" <> @double_newline <> get_random_status() <> @double_newline <> "What will you do?> ")
    {:ok, data} = :gen_tcp.recv(socket, 0)

    case String.strip(data) do
      "quit" -> :gen_tcp.send(socket, @newline <> "Coward! Leave this place and never return!" <> @newline)
      "north" -> 
        Player.move(player_name, :north)
        loop({player_name, socket})
      "south" -> 
        Player.move(player_name, :south)
        loop({player_name, socket})
      "east" -> 
        Player.move(player_name, :east)
        loop({player_name, socket})
      "west" -> 
        Player.move(player_name, :west)
        loop({player_name, socket})
      "who" -> 
        display_other_players(player_name, position, socket)
        loop({player_name, socket})
      "search" -> 
        display_items(items, socket)
        loop({player_name, socket})
      "take " <> item -> 
        try_take(player_name, items, item, socket)
        loop({player_name, socket})
      "bag" -> 
        display_bag_contents(player_name, socket)
        loop({player_name, socket})
      _ -> 
        :gen_tcp.send(socket, "What nonsense is this? You can only say: north, south, east, west, who, search, take, bag." <> @double_newline)
        loop({player_name, socket})
    end
  end
end
