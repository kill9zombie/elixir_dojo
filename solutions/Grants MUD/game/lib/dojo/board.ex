defmodule Game.Board do
  require Logger

  @forest_edge {"You have reached the edge of the forest.  There is nothing beyond but inky darkness, an unpenetrable bog, and misery. Turn back!", []}
  
  @doc """
  Starts a new game.
  """
  def start_link do
    Agent.start_link(fn -> newboard end, name: __MODULE__)
  end

  @doc """
  Setup a new board/course.
  """
  def newboard do
    [
      [@forest_edge, @forest_edge, @forest_edge, @forest_edge, @forest_edge ],
      [@forest_edge, {"You find yourself surrounded by quicksand.", [:rope]}, {"An old, gnarled tree towers before you.", [:crow, :key]}, {"You stand before the skeleton of a small child.", [:dagger]}, {"A stream pools into a small pond between the trees.", [:fishing_rod]}, @forest_edge ],
      [@forest_edge, {"A clearing opens up before you, the trees thinning ahead.", []}, {"You stumble across a makeshift tombstone, 'RIP my love' scratched hastily into the wood.", [:skull, :mushroom]}, {"You stand in front of a small bridge crossing a stream.", [:plank]}, @forest_edge ],
      [@forest_edge, {"You enter a marsh.", [:weeds]}, {"You are standing in the Forest of Doom.", [:apple, :stick]}, {"You come across a small woodsman's shed.", [:axe]}, @forest_edge ],
      [@forest_edge, {"You have entered a small clearing in the trees.", []}, {"You are standing on a path leading out of the forest.", [:rock]}, {"You find a small stream winding through the trees.", [:dead_fish]}, @forest_edge ],
      [@forest_edge, @forest_edge, @forest_edge, @forest_edge, @forest_edge ]
    ]
  end

  @doc"We want the start position for a new player"
  def start_position do
    # {row, column}
    {3,2}
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
