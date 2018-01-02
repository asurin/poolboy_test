defmodule PoolboyTest.Sizer do
  def size(path) do
    :timer.sleep(500)
    %{size: size} = File.stat!(path)
    size
  end
end