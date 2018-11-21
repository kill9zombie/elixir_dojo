defmodule Game.Acceptor do
  require Logger
  alias Game.Player, as: Player
  alias Game.Board, as: Board

  #
  # The main Elixir documentation reference is here:
  #  http://elixir-lang.org/docs.html
  #
  # .. just watch the version that you're using.
  #
  # There's a really good into to Elixir too (just longer than this dojo)
  #
  # http://elixir-lang.org/getting-started/introduction.html
  #
  #

  # This is our entry point, it's called by the Listener when they add us to the Task Supervisor.
  def start(socket) do
    # From here, we'll just display the introduction screen to the user, then go into the main loop.
    intro(socket) |> loop
  end

  # This is just the intro or splash banner that the user sees.
  # The String or IO.ANSI modules can be handy.
  defp greeting do
    IO.ANSI.cyan <> "\u232c Welcome to Leeds Code Dojo! \u232c\r\n\r\n" <> IO.ANSI.default_color
  end

  # This is the introduction, where we show the banner and register the user.
  defp intro(socket) do
    :gen_tcp.send(socket, greeting())
    :gen_tcp.send(socket, "player name: ")

    # If the socket is in raw mode, we can select how many bytes to read.
    # In our case it isn't, 0 just means 'all bytes'.
    # http://www.erlang.org/doc/man/gen_tcp.html#recv-2
    {:ok, data} = :gen_tcp.recv(socket, 0)
    Logger.debug fn -> "#{__MODULE__} received data: #{inspect data}" end

    player_name = String.trim(data)
    Logger.debug fn -> "#{__MODULE__} player name: #{inspect player_name}" end
    # Register the player, this will either add a new player or
    # return their existing record.  See the help with `h Game.Player.regiser`.
    Player.register(player_name)

    # The last term is returned by the function.
    {player_name, socket}
  end

  # This is the main loop.
  defp loop({player_name, socket}) do
    # Get the player's position on the board and display
    # the text to the user.
    {:ok, position} = Player.position(player_name)
    {:ok, {room_text}} = Board.room(position)
    :gen_tcp.send(socket, "#{room_text}\r\n")
    :gen_tcp.send(socket, "\r\n")

    # Now we get a command from the user and deal with the result.
    :gen_tcp.send(socket, "command> ")
    {:ok, data} = :gen_tcp.recv(socket, 0)
    Logger.debug fn -> "#{__MODULE__} received data: #{inspect data}" end

    case String.trim(data) do
      "quit" -> :gen_tcp.send(socket, "goodbye\r\n")
    end
  end

end
