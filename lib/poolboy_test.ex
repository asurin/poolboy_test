defmodule PoolboyTest do
  use Application

  def start(_type, _args) do
    poolboy_config = [
      {:name, {:local, pool_name()}},
      {:worker_module, PoolboyTest.Worker},
      {:size, 2},
      {:max_overflow, 1}
    ]

    children = [
      :poolboy.child_spec(pool_name(), poolboy_config, [])
    ]

    options = [
      strategy: :one_for_one,
      name: PoolboyTest.Supervisor
    ]

    Supervisor.start_link(children, options)
  end

  def basic_pool(path) do
    pool_square(path)
  end

  def parallel_pool(paths) do
    Enum.each(
      paths,
      fn(path) -> spawn( fn() -> pool_square(path) end ) end
    )
  end

  def paths() do
    Path.wildcard("#{File.cwd!()}/**/*")
  end

  defp pool_square(path) do
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
