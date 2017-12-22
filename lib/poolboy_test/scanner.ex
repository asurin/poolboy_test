defmodule PoolboyTest.Scanner do
  use GenServer

  # client

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{state: :idle}, name: Scanner)
  end

  def scan(path) do
    GenServer.call(Scanner, {:scan, path})
  end

  def state() do
    GenServer.call(Scanner, {:state})
  end

  def results() do
    GenServer.call(Scanner, {:results})
  end

  # server

  def init(state) do
    {:ok, state}
  end

  def handle_call({:scan, _path}, _from, %{state: :scanning} = state) do
    {:reply, {:busy}, state}
  end
  def handle_call({:scan, _path}, _from, %{state: :done} = state) do
    {:reply, {:busy}, state}
  end
  def handle_call({:scan, path}, _from, %{state: :idle}) do
    {:reply, {:ok}, %{state: :scanning, monitor: scan_worker(path)}}
  end

  def handle_call({:state}, _from, state) do
    {:reply, {:state, state.state}, state}
  end

  def handle_call({:results}, _from, %{state: :done, results: results}) do
    {:reply, {:results, results}, %{state: :idle}}
  end
  def handle_call({:results}, _from, _state) do
    {:reply, {:no_results}, state}
  end

  def handle_info({:pass_results, results}, %{state: :scanning, monitor: ref}) do
    IO.puts "4"
    Process.demonitor(ref)
    IO.puts "5"
    {:noreply, %{state: :done, results: results}}
  end
  def handle_info({:DOWN, _ref, :process, _object, _reason}, %{state: :scanning}) do
    {:noreply, %{state: :idle}}
  end

  defp scan_worker(path) do
    {:ok, scanner} = PoolboyTest.ScanWorker.start_link([])
    ref = Process.monitor(scanner)
    PoolboyTest.ScanWorker.perform(scanner, "/home/asurin/Development", self())
    ref
  end
end