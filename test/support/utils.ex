defmodule TestUtils do
  @moduledoc false
  use Boundary, check: [in: true, out: false]

  @spec caught((() -> any)) :: Exception.t() | term | nil
  def caught(f) do
    f.()
  rescue
    e -> e
  catch
    :exit, reason -> reason
    value -> value
  end
end
