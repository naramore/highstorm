defmodule Oath.Stepper do
  @moduledoc false
  import Oath.Utils, only: [proper_list?: 1, is_proper_list: 1]
  alias Oath.{ConformError, Spec}

  defstruct enum: [],
            index: 0

  @type t :: %__MODULE__{
          enum: Enumerable.t(),
          index: non_neg_integer
        }

  @spec new(Enumerable.t(), non_neg_integer) :: t
  def new(enum \\ [], index \\ 0) do
    %__MODULE__{
      enum: enum,
      index: index
    }
  end

  @spec init(t | Enumerable.t(), Spec.route()) :: {t, Spec.route()}
  def init(%__MODULE__{index: i} = stepper, route) do
    {stepper, [i | route]}
  end

  def init(enum, route) do
    {new(enum, 0), [0 | route]}
  end

  @spec inc(t) :: t
  def inc(stepper) do
    stepper
    |> Map.update!(:index, &(&1 + 1))
    |> Map.update!(:enum, &tl/1)
  end

  @spec terminate(t, Spec.route()) :: {list, Spec.route()}
  def terminate(stepper, [_ | route]) do
    {to_list(stepper), route}
  end

  @spec to_list(t | Enumerable.t()) :: list
  def to_list(stepper) do
    Enum.to_list(stepper.enum)
  end

  @spec empty?(t | Enumerable.t()) :: boolean
  def empty?(%__MODULE__{enum: enum}), do: Enum.empty?(enum)
  def empty?(enum), do: Enum.empty?(enum)

  @spec conform_while(
          Spec.t(),
          Spec.path(),
          Spec.via(),
          Spec.route(),
          Spec.value(),
          (Spec.result(), Spec.t(), list -> :halt | {:cont | :halt, Spec.result()}),
          list
        ) :: Spec.result()
  def conform_while(spec, path, via, route, rest, fun, acc \\ []) do
    case fun.(conform(spec, path, via, route, rest), spec, acc) do
      :halt ->
        {:ok, :lists.reverse(acc), rest}

      {:halt, {:ok, conformed, rest}} ->
        {:ok, :lists.reverse([conformed | acc]), rest}

      {:cont, {:ok, conformed, rest}} ->
        conform_while(spec, path, via, route, rest, fun, [conformed | acc])

      {_, {:error, ps}} ->
        {:error, ps}
    end
  end

  @spec conform(Spec.t(), Spec.path(), Spec.via(), Spec.route(), Spec.value()) :: Spec.result()
  def conform(spec, path, via, route, %__MODULE__{} = val) do
    conform_impl(spec, path, via, init(val, route))
  end

  def conform(spec, path, via, route, val) when is_proper_list(val) do
    conform_impl(spec, path, via, init(val, route))
  end

  def conform(_spec, path, via, route, val) when is_list(val) do
    {:error, [ConformError.new_problem(&proper_list?/1, path, via, route, val)]}
  end

  def conform(_spec, path, via, route, val) do
    {:error, [ConformError.new_problem(&is_list/1, path, via, route, val)]}
  end

  @spec conform_impl(Spec.t(), Spec.path(), Spec.via(), {t, Spec.route()}) :: Spec.result()
  defp conform_impl(spec, path, via, {%__MODULE__{enum: []}, [_ | route]}) do
    {:error, [ConformError.new_problem(spec, path, via, route, [], :insufficient_data)]}
  end

  defp conform_impl(spec, path, via, {stepper, route}) do
    case Spec.conform(spec, path, via, route, hd(stepper.enum)) do
      {:ok, conformed, _} -> {:ok, conformed, inc(stepper)}
      {:error, ps} -> {:error, ps}
    end
  end

  defimpl Inspect do
    def inspect(stepper, opts) do
      @protocol.inspect(stepper.enum, opts)
    end
  end
end
