defmodule ElixirDojo.Printer do
  require Logger
  use GenServer

  @moduledoc """
  A module to print characters to a file.

  """

  @timeout 1000
  @output_file Application.get_env(:elixir_dojo, :output_file)

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

  This adds the list to the stack of things to print.
  We print a line once a second.
  """
  def print(pid, list) do
    data = list |> Enum.map_join &character_map(&1)
    GenServer.cast(pid, {:push, data})
  end

  def stop(pid) do
    GenServer.cast(pid, :stop)
  end

  defp character_map(0), do: " "
  defp character_map(1), do: "="

  ###
  # GenServer callbacks
  #

  def init(_opts) do
    Process.flag(:trap_exit, true)
    {:ok, file} = File.open @output_file, [:write]
    {:ok, %{file: file, data: []}, @timeout}
  end


  def handle_cast({:push, msg}, state = %{file: file, data: []}) do
    Logger.debug fn -> "Adding #{inspect msg} to the buffer" end
    {:noreply, %{file: file, data: [msg]}, @timeout}
  end

  def handle_cast({:push, msg}, %{file: file, data: data}) do
    Logger.debug fn -> "Adding #{inspect msg} to the buffer" end
    {:noreply, %{file: file, data: Enum.reverse(data, msg)}, @timeout}
  end

  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end


  def handle_info(:timeout, state = %{file: file, data: []}) do
    {:noreply, state, @timeout}
  end

  def handle_info(:timeout, state = %{file: file, data: data}) do
    [head|tail] = data
    Logger.debug fn -> "handle_info: writing: #{inspect head}" end
    IO.binwrite file, head
    {:noreply, %{file: file, data: tail}, @timeout}
  end

  def terminate(reason, state = %{file: file}) do
    Logger.warn fn -> "Terminating: #{inspect reason}" end
    File.close file
    :ok
  end

end
