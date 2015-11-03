defmodule Game.PlayerPosition do
  @moduledoc """
  An Agent to track the player's position in the game.

  """

#   The state looks something like this:
# 
#   [
#     {"jim", {2,3}},
#     {"bob", {2,5}}
#   ]
# 
#   .. where "jim" and "bob" are the names of the players, followed by {row, column}
#   positions on the board

  alias Game.Board

  @doc """
  Starts a new game.
  """
  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  @doc"We want the start position for a new player"
  def start_position do
    Board.start_position
  end

  @spec position(String.t) :: {:ok, {integer(), integer}} | {:error, :player_not_found}
  def position(player_name) do
    Agent.get(__MODULE__, fn(state) ->
      _find_player_pos(player_name, state)
    end)
  end

  defp _find_player_pos(player_name, []), do: {:error, :player_not_found}
  defp _find_player_pos(player_name, [{player_name, position} | tail]), do: {:ok, position}
  defp _find_player_pos(player_name, [_head|tail]), do: _find_player_pos(player_name, tail)

  def player_exists?(player_name) do
    case position(player_name) do
      {:error, :player_not_found} -> false
      _ -> true
    end
  end

  @spec new_player(String.t) :: :ok
  def new_player(player_name) when is_bitstring(player_name) do
    if player_exists?(player_name) do
      {:error, :duplicate_player}
    else
      Agent.update(__MODULE__, fn(state) ->
        [ {player_name, start_position} | state ]
      end)
    end
  end

  @doc"""
  Move the player.

  The grid looks like:
   0 1 2 3 4
  0
  1
  2
  3
  4
 
  Returns :ok if all went well, {:error, reason} on errors.
  """
  def move_player(player_name, :north), do: _update_player_position(player_name, -1, 0)
  def move_player(player_name, :south), do: _update_player_position(player_name, 1, 0)
  def move_player(player_name, :east), do: _update_player_position(player_name, 0, 1)
  def move_player(player_name, :west), do: _update_player_position(player_name, 0, -1)

  defp _update_player_position(player_name, row_offset, column_offset) do
    case position(player_name) do
      {:ok, {row, column}} ->
        # Are we about to move to a valid location?
        case Board.room({row + row_offset, column + column_offset}) do
          {:ok, _} ->
            Agent.update(__MODULE__, fn(state) ->
              # Find the other players
              other_players = Enum.filter(state, fn({player, pos}) -> player != player_name end)
              # Replace this player's record
              [ {player_name, {row + row_offset, column + column_offset}} | other_players ]
            end)
          {:error, room_reason} ->
            {:error, room_reason}
        end
      {:error, reason} ->
        {:error, reason}
    end
  end

end
