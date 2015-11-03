defmodule Game.Board do
  require Logger

  @player_map_key :player_map
  @board_key :board
  
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
      ["one", "two" ,"three"],
      ["four","five","six"],
      ["seven", "eight", "nine"]
    ]
  end

  @doc"We want the start position for a new player"
  def start_position do
    # {row, column}
    {2,1}
  end

  @doc """
  Find the text for a given row and column on the board.

  Returns {:ok, text} if everything's ok, or {:error, :bad_position} if you've gone out of bounds.
  """
  def room({row, _column}) when row < 0, do: {:error, :bad_position}
  def room({_row, column}) when column < 0, do: {:error, :bad_position}
  def room({row, column}) do
    Logger.debug fn -> "Fetching row: #{inspect row} column: #{inspect column}" end
    Agent.get(__MODULE__, fn(board) ->
      board |> Enum.at(row,[]) |>  Enum.at(column)
    end) |> _room
  end
  defp _room(nil), do: {:error, :bad_position}
  defp _room(text), do: {:ok, text}

end
