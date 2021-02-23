defmodule Oath.Enum do
  @moduledoc false
  @behaviour Access

  defstruct spec: nil,
            kind: nil,
            into: nil,
            min_length: 0,
            max_length: nil,
            distinct?: false

  @type t :: %__MODULE__{
          spec: Oath.t(),
          kind: Collectable.t(),
          into: Collectable.t() | nil,
          min_length: non_neg_integer,
          max_length: non_neg_integer | nil,
          distinct?: boolean
        }

  @impl Access
  def fetch(_term, _key) do
    :error
  end

  @impl Access
  def get_and_update(data, _key, _function) do
    {nil, data}
  end

  @impl Access
  def pop(data, _key) do
    {nil, data}
  end

  @spec new(Oath.t(), keyword) :: t
  def new(spec, _opts \\ []) do
    %__MODULE__{
      spec: spec
    }
  end

  defimpl Oath.Spec do
    def conform(_spec, _path, _via, _route, _val) do
      {:error, []}
    end
  end

  defimpl Inspect do
    def inspect(_term, _opts) do
      ""
    end
  end
end
