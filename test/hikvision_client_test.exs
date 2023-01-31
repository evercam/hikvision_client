defmodule HikvisionClientTest do
  use ExUnit.Case
  doctest HikvisionClient

  test "greets the world" do
    assert HikvisionClient.hello() == :world
  end
end
