defmodule Oath.Alt do
  @moduledoc false
  @behaviour Access

  defstruct specs: [],
            regex?: false

  @type t :: %__MODULE__{
          specs: [{Oath.key(), Oath.t()}, ...],
          regex?: boolean
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

  @spec new([{Oath.key(), Oath.t()}, ...], boolean) :: t
  def new(specs, regex? \\ false) do
    # TODO: check for duplicate keys
    %__MODULE__{
      specs: specs,
      regex?: regex?
    }
  end

  defimpl Oath.Spec do
    # alias Oath.Stepper

    def conform(%@for{regex?: false, specs: [{k, spec}]}, path, via, route, val) do
      case @protocol.conform(spec, [k | path], via, route, val) do
        {:ok, conformed, rest} -> {:ok, %{k => conformed}, rest}
        {:error, ps} -> {:error, ps}
      end
    end

    def conform(%@for{regex?: false} = alt, path, via, route, val) do
      Enum.reduce_while(alt.specs, {:error, []}, fn
        _, {:ok, conformed, rest} ->
          {:halt, {:ok, conformed, rest}}

        {k, spec}, {:error, acc} ->
          case @protocol.conform(spec, [k | path], via, route, val) do
            {:error, problems} -> {:cont, {:error, problems ++ acc}}
            {:ok, conformed, rest} -> {:halt, {:ok, [%{k => conformed}], rest}}
          end
      end)
    end

    # def conform(alt, path, via, route, val) do
    #   Stepper.conform_while(alt, path, via, route, val, fn

    #   end)
    # end
  end
end
