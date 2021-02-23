defmodule Oath.Cat do
  @moduledoc false
  @behaviour Access

  defstruct specs: []

  @type t :: %__MODULE__{
          specs: [{Oath.key(), Oath.t()}, ...]
        }

  @impl Access
  def fetch(%__MODULE__{specs: specs}, key) do
    Keyword.fetch(specs, key)
  end

  @impl Access
  def get_and_update(alt, key, function) do
    Map.get_and_update(alt, :specs, &Keyword.get_and_update(&1, key, function))
  end

  @impl Access
  def pop(alt, key) do
    Map.get_and_update(alt, :specs, &Keyword.pop(&1, key))
  end

  @spec new([{Oath.key(), Oath.t()}, ...]) :: t
  def new(specs) do
    # TODO: check for duplicate keys
    %__MODULE__{
      specs: specs
    }
  end

  defimpl Oath.Spec do
    alias Oath.Stepper

    # FIXME: ???
    def conform(%@for{specs: specs}, path, via, route, val) do
      Enum.reduce_while(specs, {:ok, %{}, val}, fn
        _, {:error, ps} ->
          {:halt, {:error, ps}}

        {key, spec}, {:ok, acc, rest} ->
          case Stepper.conform(spec, [key | path], via, route, rest) do
            {:error, problems} -> {:halt, {:error, problems}}
            {:ok, c, r} -> {:cont, {:ok, Map.put(acc, key, c), r}}
          end
      end)
    end
  end
end
