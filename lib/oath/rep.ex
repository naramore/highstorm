defmodule Oath.Rep do
  @moduledoc false
  @behaviour Access

  defstruct spec: nil,
            min: 0,
            max: nil

  @type t :: %__MODULE__{
          spec: Oath.t(),
          min: non_neg_integer,
          max: pos_integer | nil
        }

  @impl Access
  def fetch(%__MODULE__{spec: spec}, key) do
    Access.fetch(spec, key)
  end

  @impl Access
  def get_and_update(rep, key, function) do
    Map.get_and_update(rep, :spec, &Access.get_and_update(&1, key, function))
  end

  @impl Access
  def pop(rep, key) do
    Map.get_and_update(rep, :spec, &Access.pop(&1, key))
  end

  @spec new(Oath.t(), non_neg_integer, pos_integer | nil) :: t
  def new(spec, min \\ 0, max \\ nil) do
    %__MODULE__{
      spec: spec,
      min: min,
      max: max
    }
  end

  @spec zero_or_more(Oath.t()) :: t
  def zero_or_more(spec) do
    new(spec, 0, nil)
  end

  @spec one_or_more(Oath.t()) :: t
  def one_or_more(spec) do
    new(spec, 1, nil)
  end

  @spec maybe(Oath.t()) :: t
  def maybe(spec) do
    new(spec, 0, 1)
  end

  defimpl Oath.Spec do
    alias Oath.Stepper

    def conform(rep, path, via, route, val) do
      Stepper.conform_while(rep, path, via, route, val, fn
        {:error, ps}, rep, acc when length(acc) < rep.min ->
          {:halt, {:error, ps}}

        {:error, _}, _, _ ->
          :halt

        {:ok, conformed, rest}, rep, acc when not is_nil(rep.max) and rep.max > length(acc) + 1 ->
          {:halt, {:ok, conformed, rest}}

        {:ok, conformed, rest}, _, _ ->
          {:cont, {:ok, conformed, rest}}
      end)
    end
  end
end
