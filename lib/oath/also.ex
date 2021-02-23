defmodule Oath.Also do
  @moduledoc false
  @behaviour Access

  defstruct specs: [],
            type: :default

  @type t :: %__MODULE__{
          specs: [Oath.t()],
          type: type
        }

  @type type :: :default | :union | :regex

  @impl Access
  def fetch(also, key) do
    case find_matching_key(also, key) do
      {value, _} -> {:ok, value}
      _ -> :error
    end
  end

  @impl Access
  def get_and_update(also, key, function) do
    update_matching_key(also, key, &Access.get_and_update(&1, &2, function))
  end

  @impl Access
  def pop(also, key) do
    update_matching_key(also, key, &Access.pop/2)
  end

  @spec new([Oath.t()], type) :: t
  def new(specs \\ [], type \\ :default) do
    %__MODULE__{
      specs: specs,
      type: type
    }
  end

  @spec update_matching_key(t, key, (Oath.t(), key -> {any, Oath.t()})) :: {any, t} when key: any
  defp update_matching_key(%__MODULE__{specs: specs} = also, key, accessor) do
    case find_matching_key(also, key) do
      {_, index} ->
        {value, spec} =
          also.specs
          |> Enum.at(index)
          |> accessor.(key)

        {value, %{also | specs: List.replace_at(specs, index, spec)}}

      _ ->
        {nil, also}
    end
  end

  @spec find_matching_key(t | [Oath.t()], any, non_neg_integer) :: {any, non_neg_integer} | nil
  defp find_matching_key(also_or_specs, key, index \\ 0)

  defp find_matching_key(%__MODULE__{specs: specs}, key, index) do
    find_matching_key(specs, key, index)
  end

  defp find_matching_key([], _key, _index), do: nil

  defp find_matching_key([spec | specs], key, index) do
    case Access.fetch(spec, key) do
      {:ok, value} -> {value, index}
      :error -> find_matching_key(specs, key, index + 1)
    end
  end

  defimpl Oath.Spec do
    # alias Oath.{ConformError, Stepper}
    alias Oath.ConformError

    def conform(%@for{type: :union, specs: specs}, path, via, route, val) when is_map(val) do
      specs
      |> Enum.map(&@protocol.conform(&1, path, via, route, val))
      |> Enum.reduce({:ok, %{}, []}, fn
        {:ok, x, _}, {:ok, acc, _} -> {:ok, Map.merge(acc, x), []}
        {:error, ps}, _ -> {:error, ps}
        _, {:error, ps} -> {:error, ps}
        {:error, ps}, {:error, acc} -> {:error, ps + acc}
      end)
    end

    def conform(%@for{type: :union}, path, via, route, val) do
      {:error, [ConformError.new_problem(&is_map/1, path, via, route, val)]}
    end

    def conform(%@for{specs: []}, _path, _via, _route, val) do
      {:ok, val, []}
    end

    def conform(%@for{type: :default, specs: specs}, path, via, route, val) do
      Enum.reduce_while(specs, {:ok, val, []}, fn
        _, {:error, ps} ->
          {:halt, {:error, ps}}

        spec, {:ok, conformed, _} ->
          case @protocol.conform(spec, path, via, route, conformed) do
            {:ok, _, _} = success -> {:cont, success}
            {:error, _} = failure -> {:halt, failure}
          end
      end)
    end

    # def conform(%@for{type: :regex} = also, path, via, route, val) do
    #   conform_impl(also, path, via, route, val)
    # end

    # @spec conform_impl(@for.t, @protocol.path, @protocol.via, @protocol.route, @protocol.value, [...]) :: @protocol.result
    # defp conform_impl(_also, _path, _via, _route, _rest, _acc \\ []) do
    #   case Stepper.conform(%{also | type: :default}, path, via, route, rest) do
    #     {:error, ps} -> {:error, ps}
    #     {:ok, conformed, rest} ->
    #       if Stepper.empty?(rest) do
    #         {:ok, :lists.reverse([conformed | acc]), []}
    #       else
    #         conform_impl(also, path, via, route, rest, [conformed | acc])
    #       end
    #   end
    # end
  end
end
