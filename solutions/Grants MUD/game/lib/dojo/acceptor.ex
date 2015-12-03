defmodule Game.Acceptor do
  require Logger
  
  import Enum
  
  alias Game.Player, as: Player
  alias Game.Board, as: Board
  
  @newline "\r\n"
  @double_newline "\r\n\r\n"
 
  def start(socket) do
    intro(socket) |> loop
  end

  defp send_with_newlines(text, colour, socket) do
    @newline <> text <> @newline |> send_text(colour, socket)
  end
  
  defp send_text(text, colour, socket) do
    text_colour_code =
      case colour do
        :description -> IO.ANSI.cyan
        :info -> IO.ANSI.green
        :question -> IO.ANSI.yellow
        :standard -> IO.ANSI.white
        _ -> IO.ANSI.white
      end
      
    :gen_tcp.send(socket, text_colour_code <> text)
  end
  
  defp receive_from_server(socket) do
    :gen_tcp.recv(socket, 0)
  end
  
  defp list_to_string(list) do
    list |> join ", "
  end
  
  defp get_name({name, _, _, _}) do 
    name
  end
  
  defp list_text(list, text) do
    text <> @newline <> list_to_string(list)
  end
  
  defp list_or_nothing(list, nothing_text, something_text) do
    case list |> length do
      0 -> @newline <> nothing_text <> @double_newline
      _ -> list |> list_text(something_text)
    end
  end
  
  defp display_other_players(player_name, position, socket) do
    other_players = Player.at(position) |> map(&get_name/1) |> reject(&(&1 == player_name))
    other_players |> display_items("You are completely alone, your dark thoughts slowly overcoming you.", "You are surrounded by the following low-lives:", socket)
  end
  
  defp display_bag_contents(player_name, socket) do
    {:ok, bag_contents} = Player.bag(player_name)
    bag_contents |> display_items("Your bag is completely empty, peasant!", "You have somehow managed to scavenge:", socket)
  end
  
  defp display_search_items(items, socket) do
    items |> display_items("This pitiful place has nothing of interest!", "You root around in the dirt, and eventually uncover:", socket)
  end
  
  defp display_items(items, nothing_text, something_text, socket) do
    items 
    |> list_or_nothing( nothing_text, something_text)
    |> send_with_newlines(:info, socket)
  end

  defp intro(socket) do
    "Welcome to Leeds Code Dojo! The Forest of Doom awaits..." |> send_with_newlines(:description, socket)
    @newline <> "player name: " |> send_text(:question, socket)

    {:ok, data} = socket |> receive_from_server()

    player_name = String.strip(data)

    case Player.register(player_name) do
      {:player, {name, _, _, _}} -> "I see you have returned, #{name}.  Fool!" |> send_with_newlines(:info, socket)
      {:new_player, {name, _, _, _}} -> "Welcome, brave #{name}!  You will not survive this day.." |> send_with_newlines(:info, socket)
    end

    {player_name, socket}
  end
  
  defp try_take(player_name, items, item, socket) do
    case items |> member? String.to_atom(item) do
      true -> 
        Player.add_to_bag(player_name, item)
        "You picked up #{item}.  Good for you." |> send_with_newlines(:info, socket)
      false ->
        "There is no #{item} in the room, fool!" |> send_with_newlines(:info, socket)
    end
  end
  
  defp get_random_background() do
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
     |> random
  end
  
  defp handle_user_action(input) do
    case input do
      "quit" -> {:quit, {:send, "Coward! Leave this place and never return!"}}
      dir when dir == "north" or dir == "east" or dir == "south" or dir == "west" -> {:continue, {:move, dir}}
      "who" -> {:continue, {:show_players}}
      "search" -> {:continue, {:search}}
      "take " <> item -> {:continue, {:take, item}}
      "bag" -> {:continue, {:bag}}
      _ -> {:continue, {:send, "What nonsense is this? You can only: north, south, east, west, who, search, take, bag."}}
    end
  end
  
  defp handle(action, player, position, items, socket) do
    case action do
      {:send, text} -> text |> send_with_newlines(:info, socket)
      {:move, direction} -> player |> Player.move(String.to_atom direction)
      {:show_players} -> display_other_players(player, position, socket)
      {:search} -> display_search_items(items, socket)
      {:take, item} -> player |> try_take(items, item, socket)
      {:bag} -> player |> display_bag_contents(socket)
    end
  end
  
  defp loop({player_name, socket}) do

    {:ok, position} = Player.position(player_name)
    {:ok, {room_text, items}} = Board.room(position)
    
    "#{room_text}" <> @double_newline <> get_random_background() |> send_with_newlines(:description, socket)
    
    "What will you do?" |> send_with_newlines(:question, socket)
    @newline <> "> " |> send_text(:question, socket)
    "" |> send_text(:standard, socket)
    
    {:ok, data} = socket |> receive_from_server()

    case handle_user_action(String.strip(data)) do
      {:quit, action} -> 
        action |> handle(player_name, position, items, socket)
      {:continue, action} -> 
        action |> handle(player_name, position, items, socket)
        loop({player_name, socket})
    end
  end
end
