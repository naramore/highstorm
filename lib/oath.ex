defmodule Oath do
  @moduledoc false
  use Boundary, deps: [Entry], exports: []
  alias Oath.Spec

  @type t :: Spec.t()
  @type generator :: StreamData.t(any)
  @type gen_fun :: (() -> generator)
  @type key :: atom
end

defmodule Oath.Utils do
  @moduledoc false
  alias Entry.Improper
  alias Oath.{ConformError, Spec}

  defguard is_proper_list(x) when is_list(x) and length(x) >= 0

  defdelegate proper_list?(term), to: Improper

  @spec append(any, any) :: list
  def append([], []), do: []
  def append([_ | _] = l, []), do: l
  def append([], [_ | _] = r), do: r
  def append([_ | _] = l, [_ | _] = r), do: l ++ r
  def append(l, r) when is_list(r), do: [l | r]
  def append(l, r) when is_list(l), do: Enum.concat(l, [r])
  def append(_, _), do: []

  @spec conform_head(Spec.t(), Spec.path(), Spec.via(), Spec.route(), Spec.value()) ::
          Spec.result()
  def conform_head(spec, path, via, [_ | route], []) do
    {:error, [ConformError.new_problem(spec, path, via, route, [], :insufficient_data)]}
  end

  def conform_head(spec, path, via, route, [h | t]) do
    case Spec.conform(spec, path, via, route, h) do
      {:ok, conformed, _} -> {:ok, conformed, t}
      {:error, ps} -> {:error, ps}
    end
  end
end
