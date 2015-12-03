defmodule Game.Listener do
  require Logger

  @port Application.get_env(:game, :port, 4040)

  # Basically the listener section from:
  # http://elixir-lang.org/getting-started/mix-otp/task-and-gen-tcp.html
  #

  def acceptor do
    {:ok, socket} = :gen_tcp.listen(@port,
                      [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info fn -> "#{__MODULE__} Accepting connections on port #{inspect @port}" end
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    Logger.debug fn -> "#{__MODULE__} Received connection from #{inspect :inet.peername(client)}" end
    {:ok, pid} = Task.Supervisor.start_child(Game.TaskSupervisor, fn -> Game.Acceptor.start(client) end)
    Logger.debug fn -> "#{__MODULE__} Started acceptor: #{inspect pid}" end
    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end

end
