defmodule C3ErlNif do
  @on_load :init
  @compile :debug_info

  # require IEx

  def init do
    System.cmd("make", ["erl_nif"])
    IO.puts("INIT")
    # IEx.pry()
    :ok = :erlang.load_nif("./erl_nif", 0)
  end

  def hello, do: exit(:nif_not_loaded)
  def add(_a, _b), do: exit(:nif_not_loaded)
end

IO.puts("nif#add(1+22) = #{C3ErlNif.add(1, 22)}")
IO.puts("nif#hello() = #{C3ErlNif.hello()}")
