defmodule Oath.WithGen do
  @moduledoc false
  @behaviour Access

  defstruct spec: nil,
            gen: nil

  @type t :: %__MODULE__{
          spec: Oath.t(),
          gen: Oath.gen_fun()
        }

  @impl Access
  def fetch(%__MODULE__{spec: spec}, key) do
    Access.fetch(spec, key)
  end

  @impl Access
  def get_and_update(%__MODULE__{spec: spec} = gen, key, fun) do
    {val, spec} = Access.get_and_update(spec, key, fun)
    {val, %{gen | spec: spec}}
  end

  @impl Access
  def pop(%__MODULE__{spec: spec} = gen, key) do
    {val, spec} = Access.pop(spec, key)
    {val, %{gen | spec: spec}}
  end

  @spec new(Oath.t(), Oath.gen_fun()) :: t
  def new(spec, gen_fun) do
    %__MODULE__{
      spec: spec,
      gen: gen_fun
    }
  end

  defimpl Oath.Spec do
    def conform(%@for{spec: spec}, path, via, route, val) do
      @protocol.conform(spec, path, via, route, val)
    end
  end

  defimpl Inspect do
    def inspect(%@for{spec: spec}, opts) do
      @protocol.inspect(spec, opts)
    end
  end
end
