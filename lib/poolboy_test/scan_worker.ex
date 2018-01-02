defmodule PoolboyTest.ScanWorker do
  use GenServer

  # client

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], [])
  end

  def perform(scanner, path, recipient) do
    GenServer.cast(scanner, {:perform, path, recipient})
  end

  # server

  def handle_cast({:perform, path, recipient}, _) do
    results = Path.wildcard("#{path}/**/*")
    send recipient, {:pass_results, results}
    {:noreply, nil}
  end
end