defmodule PoolboyTest.Worker do
  use GenServer

  # Client

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], [])
  end

  def size(pid, path) do
    GenServer.call(pid, {:size, path})
  end

  # Server

  def init(state) do
    {:ok, state}
  end

  def handle_call({:size, path}, _from, state) do
    result = PoolboyTest.Sizer.size(path)
    {:reply, [result], state}
  end
end