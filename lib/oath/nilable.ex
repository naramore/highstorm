defmodule Oath.Nilable do
  @moduledoc false
  @behaviour Access

  defstruct spec: nil

  @type t :: %__MODULE__{
          spec: Oath.t()
        }

  @impl Access
  def fetch(%__MODULE__{spec: spec}, key) do
    Access.fetch(spec, key)
  end

  @impl Access
  def get_and_update(nilable, key, function) do
    Map.get_and_update(nilable, :spec, &Access.get_and_update(&1, key, function))
  end

  @impl Access
  def pop(nilable, key) do
    Map.get_and_update(nilable, :spec, &Access.pop(&1, key))
  end

  @spec new(Oath.t()) :: t
  def new(spec) do
    %__MODULE__{
      spec: spec
    }
  end

  defimpl Oath.Spec do
    def conform(_nilable, _path, _via, _route, nil) do
      {:ok, nil, []}
    end

    def conform(%@for{spec: spec}, path, via, route, val) do
      @protocol.conform(spec, path, via, route, val)
    end
  end
end
