defmodule Game.Board do
  use Agent
  require Logger

  @doc """
  Starts a new game.
  """
  def start_link(_args) do
    Agent.start_link(fn -> newboard() end, name: __MODULE__)
  end

  @doc """
  Setup a new board/course.
  """
  def newboard do
    [
      [{"Edge of the forest."}, {"The cliffs of Aaaarrrrggh!"} ,{"Almscliff Crag."}, {"Edge of the forest."} ],
      [{"Edge of the forest."}, {"Mr Foleys"} ,{"The Dojo, Hai!"}, {"Edge of the forest."} ],
      [{"Edge of the forest."}, {"Town Hall."} ,{"Deserted Hospital."}, {"Edge of the forest."} ],
      [{"Edge of the forest."}, {"Welcome to the forest, please go north to start your journey."} ,{"nothing here yet!"}, {"Edge of the forest."} ],
      [{"Edge of the forest."}, {"Edge of the forest."} ,{"Edge of the forest."}, {"Edge of the forest."} ]
    ]
  end

  @doc"We want the start position for a new player"
  def start_position do
    # {row, column}
    {3,1}
  end

  @doc ~S"""
  Find the text for a given row and column on the board.

  Returns {:ok, {text}} if everything's ok, or {:error, :bad_position} if you've gone out of bounds.

  Example (We want row 3, column 1):
      iex> Game.Board.room({3,1})
      {:ok, {"Welcome to the forest, please go north to start your journey."}}
      iex>

  The board looks like this:

        North

       0 1 2 3 ...
      0
      1
      2
      3
      .
      .
        South

  """
  def room({row, _column}) when row < 0, do: {:error, :bad_position}
  def room({_row, column}) when column < 0, do: {:error, :bad_position}
  def room({row, column}) do
    Logger.debug fn -> "#{__MODULE__} Fetching row: #{inspect row} column: #{inspect column}" end
    Agent.get(__MODULE__, fn(board) ->
      board |> Enum.at(row,[]) |>  Enum.at(column)
    end) |> do_room
  end
  defp do_room(nil), do: {:error, :bad_position}
  defp do_room(term), do: {:ok, term}

end
