defmodule ElixirDojo.Printer do
  require Logger
  use GenServer

  @moduledoc """
  A module to print characters to a file.

  """

  @character "="
  @timeout 1000

  ###
  # External API
  #

  @doc """
  Start the printer.
  """
  def start_link do
    GenServer.start_link(__MODULE__, [])
  end


  @doc """
  print the list, ie: 
  
    ElixirDojo.Printer.print([0,0,1,1,1])
  """
  def print(list) do
    data = list |> Enum.map_join &character_map(&1)
    GenServer.cast(__MODULE__, [data])
  end

  defp character_map(0), do: " "
  defp character_map(1), do: @character

  ###
  # GenServer callbacks
  #

  def init(_opts) do
    Process.flags({:trap_exit, true})
    {:ok, file} = File.open @output_file, [:write]
    {:ok, %{file: file}, 1000}
  end

  def handle_cast(msg, %{file: file, data: data}) do
    {:noreply, %{file: file, data: [msg|data]}}
  end


  def handle_info(:timeout, state = %{data: []}) do
    Logger.debug fn -> "handle_info: nothing to write" end
    {:noreply, state}
  end

  def handle_info(:timeout, state = %{file: file, data: data}) do
    Logger.debug fn -> "handle_info: writing data" end
    [head|tail] = data
    IO.binwrite file, head
    {:noreply, state}
  end

  def terminate(msg, state = %{file: file}) do
    Logger.warn fn -> "Terminating" end
    File.close file
    {:ok, state}
  end

end
