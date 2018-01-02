defmodule PoolboyTest do
  use Application

  alias PoolboyTest.Scanner

  def start(_type, _args) do
    poolboy_config = [
      {:name, {:local, pool_name()}},
      {:worker_module, PoolboyTest.Worker},
      {:size, 4},
      {:max_overflow, 2}
    ]

    children = [
      PoolboyTest.Scanner,
      :poolboy.child_spec(pool_name(), poolboy_config, [])
    ]

    options = [
      strategy: :one_for_one,
      name: PoolboyTest.Supervisor
    ]

    Supervisor.start_link(children, options)
  end

  def sizes(path) do
    {:results, paths} = paths(path)
    Enum.each(
      paths,
      fn(path) -> spawn( fn() -> size(path) end ) end
    )
  end

  def simple_sizes(path) do
    {:results, paths} = paths(path)
    {:ok, worker} = PoolboyTest.Worker.start_link([])
    Enum.each(
      paths,
      fn(path) -> PoolboyTest.Worker.size(worker, path) end
    )
  end

  def paths(path) do
    Scanner.scan(path)
    {:ok, paths} = wait_for_results(nil, 0)
    paths
  end

  defp wait_for_results({:state, :done}, _) do
    {:ok, Scanner.results()}
  end
  defp wait_for_results(_, 60) do
    {:timeout}
  end
  defp wait_for_results(state, iteration) do
    :timer.sleep(1000)
    wait_for_results(Scanner.state(), iteration + 1)
  end

  defp size(path) do
    :poolboy.transaction(
      pool_name(),
      fn(pid) -> PoolboyTest.Worker.size(pid, path) end,
      :infinity
    )
  end

  defp pool_name() do
    :sizer_pool
  end
end
