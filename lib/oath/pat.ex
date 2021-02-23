defmodule Oath.Pat do
  @moduledoc false
  @behaviour Access

  defstruct specs: [],
            union?: false

  @type t :: %__MODULE__{
          specs: [Oath.t()],
          union?: boolean
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

  @spec new([Oath.t()], boolean) :: t
  def new(specs \\ [], union? \\ false) do
    %__MODULE__{
      specs: specs,
      union?: union?
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
