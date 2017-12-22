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
    IO.puts "1"
    results = Path.wildcard("#{path}/**/*")
    IO.puts "2"
    send recipient, {:pass_results, results}
    IO.puts "3"
    {:noreply, nil}
  end
end