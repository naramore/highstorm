defprotocol Meddle.Interceptor do
  @spec invoke(t, Meddle.context()) :: Meddle.context()
  def invoke(interceptor, context)

  @spec coerce(t) :: t
  def coerce(interceptor)
end

defimpl Meddle.Interceptor, for: Function do
  def invoke(fun, context) do
    @protocol.invoke(%{enter: fun}, context)
  end

  def coerce(fun) do
    fun
  end
end

defimpl Meddle.Interceptor, for: Map do
  alias Meddle.Utils

  def invoke(map, context) do
    Utils.invoke(context, map, &Map.get(&2, &1))
  end

  def coerce(map) do
    map
  end
end

defimpl Meddle.Interceptor, for: Atom do
  alias Meddle.Utils

  def invoke(module, context) do
    Utils.invoke(context, module, &extract/2)
  end

  def coerce(module) do
    module
  end

  @spec extract(Meddle.direction(), module) :: function
  defp extract(:enter, module), do: &module.enter/1
  defp extract(:leave, module), do: &module.leave/1
  defp extract(:error, module), do: &module.error/2
end

defimpl Meddle.Interceptor, for: List do
  alias Meddle.Pipe

  def invoke(_list, context) do
    context
    |> Meddle.coerce()
    |> (&@protocol.invoke(Meddle.get_container(&1), &1)).()
  end

  def coerce(list) do
    Pipe.new(coerce_impl(list))
  end

  @spec coerce_impl([...]) :: [@protocol.t]
  defp coerce_impl([]), do: []
  defp coerce_impl([h | t]), do: [@protocol.coerce(h) | coerce_impl(t)]
end
