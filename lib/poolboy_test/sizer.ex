defmodule PoolboyTest.Sizer do
  def size(path) do
    :timer.sleep(2000)
    %{size: size} = File.stat!(path)
    size
  end
end