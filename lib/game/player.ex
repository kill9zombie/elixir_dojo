defmodule Game.Player do
  @moduledoc """
  A server to track the player's position in the game.

  """

  #   The state looks something like this:
  # 
  #   [
  #     {"jim", {2,3}, []},
  #     {"bob", {2,5}, []}
  #   ]
  # 
  #   .. where "jim" and "bob" are the names of the players, followed by {row, column}
  #   positions on the board, then any items they're carrying.

  use GenServer

  alias Game.Board, as: Board

  ## Public API

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc ~S"""
  Registers a new player.

  If the player's already registered in the system then we'll return:
  {:player, {player_name, {row, column}, bag}}

  If we've just registered a new player, we'll return:
  {:new_player, {player_name, {row, column}, []}}

  Example

      iex> Game.Player.register("bob")
      {:new_player, {"bob", {2, 1}, []}}
      iex> Game.Player.register("bob")
      {:player, {"bob", {2, 1}, []}}

  """
  def register(player_name) do
    GenServer.call(__MODULE__, {:register, player_name})
  end

  @doc ~S"""
  Returns the position for our player.

  Example

      iex> Game.Player.register("bob")
      {:new_player, {"bob", {2, 1}, []}}
      iex> Game.Player.position("bob")
      {:ok, {2, 1}}
      iex> Game.Player.position("alice")
      {:error, :player_not_found}

  """
  def position(player_name) do
    GenServer.call(__MODULE__, {:position, player_name})
  end

  @doc ~S"""
  Moves our player either north, south, east or west.

  The grid looks like:

       0 1 2 3 4
      0
      1
      2
      3
      4
 
  Returns :ok if all went well, {:error, reason} on errors.

  Example:

      iex> Game.Player.register("carol")
      {:new_player, {"carol", {2, 1}, []}}
      iex> Game.Player.move("carol", :north)
      :ok
      iex> Game.Player.move("carol", :south)
      :ok
      iex> Game.Player.move("carol", :east) 
      :ok
      iex> Game.Player.move("carol", :west)
      :ok
      iex> Game.Player.move("carol", :bad)  
      {:error, :bad_movement}
      iex> Game.Player.move("fred", :north)
      {:error, :player_not_found}


  """
  def move(player_name, :north), do: GenServer.call(__MODULE__, {:move, player_name, :north})
  def move(player_name, :south), do: GenServer.call(__MODULE__, {:move, player_name, :south})
  def move(player_name, :east), do: GenServer.call(__MODULE__, {:move, player_name, :east})
  def move(player_name, :west), do: GenServer.call(__MODULE__, {:move, player_name, :west})
  def move(_player_name, _), do: {:error, :bad_movement}

  @doc ~S"""
  Returns a list of players at a position.
  
      at({row, column})

  Example:

      iex> Game.Player.register("jim")
      {:new_player, {"jim", {3, 1}, []}}
      iex> Game.Player.register("bob")
      {:new_player, {"bob", {3, 1}, []}}
      iex> Game.Player.at({3,1})
      [{"bob", {3, 1}}, {"jim", {3, 1}}]

  """
  def at({row, column}) do
    GenServer.call(__MODULE__, {:players_at, {row, column}})
  end

  @doc ~S"""
  Get the contents of a player's bag.

  Example

      iex> Game.Player.register("becky")
      {:new_player, {"becky", {3, 1}, []}}
      iex> Game.Player.add_to_bag("becky", {:gold, 2})
      :ok
      iex> Game.Player.bag("becky")
      {:ok, [gold: 2]}

  """
  def bag(player_name) do
    GenServer.call(__MODULE__, {:bag, player_name})
  end

  @doc ~S"""
  Add something to the player's bag.

  Example

      iex> Game.Player.register("becky")
      {:new_player, {"becky", {3, 1}, []}}
      iex> Game.Player.add_to_bag("becky", {:gold, 2})
      :ok
      iex> Game.Player.bag("becky")
      {:ok, [gold: 2]}
  """
  def add_to_bag(player_name, term) do
    GenServer.call(__MODULE__, {:add_to_bag, player_name, term})
  end

  ## Private functions

  defp find_player(registry, player_name) do
    Enum.find(registry, :no_player, fn({name, _, _}) -> name == player_name end)
  end

  # If we're going to go outside the board, then Board.room
  # returns {:error, reason}, otherwise we're ok to update the position.
  #
  defp do_move({row, column}, row_offset, column_offset) do
    case Board.room({row + row_offset, column + column_offset} ) do
      {:error, _reason} ->
        {row, column}
      {:ok, _} ->
        {row + row_offset, column + column_offset}
    end
  end

  defp do_move_position(position, :north), do: do_move(position, -1, 0)
  defp do_move_position(position, :south), do: do_move(position, 1, 0)
  defp do_move_position(position, :east), do: do_move(position, 0, 1)
  defp do_move_position(position, :west), do: do_move(position, 0, -1)
    

  ## GenServer Callbacks below

  def init(_args) do
    state = []
    {:ok, state}
  end

  def handle_call({:register, player_name}, _from, state) do
    {token, player_record} = case find_player(state, player_name) do
      :no_player ->
        {:new_player, {player_name, Board.start_position, []}}
      {player_name, position, bag} ->
        {:player, {player_name, position, bag}}
    end

    {:reply, {token, player_record}, [ player_record | state ]}
  end

  def handle_call({:position, player_name}, _from, state) do
    case find_player(state, player_name) do
      :no_player ->
        {:reply, {:error, :player_not_found}, state}
      {^player_name, position, _bag} ->
        {:reply, {:ok, position}, state}
    end
  end

  def handle_call({:move, player_name, direction}, _from, state) do
    case find_player(state, player_name) do
      :no_player ->
        {:reply, {:error, :player_not_found}, state}
      {^player_name, position, bag} ->
        other_players = Enum.reject(state, fn({name, _, _}) -> name == player_name end)
        new_position = do_move_position(position, direction)
        {:reply, :ok, [ {player_name, new_position, bag} | other_players ]}
    end
  end

  def handle_call({:players_at, {row, column}}, _from, state) do
    players = Enum.filter(state, fn({_player_name, position, _bag}) -> position == {row, column} end)
    {:reply, players, state}
  end

  def handle_call({:bag, player_name}, _from, state) do
    case find_player(state, player_name) do
      :no_player ->
        {:reply, {:error, :player_not_found}, state}
      {^player_name, _position, bag} ->
        {:reply, {:ok, bag}, state}
    end
  end

  def handle_call({:add_to_bag, player_name, item}, _from, state) do
    case find_player(state, player_name) do
      :no_player ->
        {:reply, {:error, :player_not_found}, state}
      {^player_name, position, old_bag} ->
        other_players = Enum.reject(state, fn({name, _, _}) -> name == player_name end)
        {:reply, :ok, [ {player_name, position, [ item | old_bag ]} | other_players ]}
    end
  end

  
end
