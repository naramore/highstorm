defprotocol Oath.Spec do
  alias Oath.ConformError

  @fallback_to_any true

  @type path :: [Oath.key()]
  @type via :: [Oath.Ref.t()]
  @type route :: [term]
  @type value :: any
  # @type opt ::
  #   {:path, path}
  #   | {:via, via}
  #   | {:route, route}
  @type conformed :: any
  @type rest :: any
  @type result :: {:ok, conformed, rest} | {:error, [ConformError.problem()]}

  @spec conform(t, path, via, route, value) :: result
  def conform(spec, path, via, route, val)

  # TODO: maybe???
  # @spec conform(t, value, [opt]) :: result
  # def conform(spec, value, opts \\ [])
end

defimpl Oath.Spec, for: Function do
  def conform(_spec, _path, _via, _route, _val) do
    {:error, []}
  end
end

defimpl Oath.Spec, for: List do
  def conform(_spec, _path, _via, _route, _val) do
    {:error, []}
  end
end

defimpl Oath.Spec, for: Tuple do
  def conform(_spec, _path, _via, _route, _val) do
    {:error, []}
  end
end

defimpl Oath.Spec, for: Map do
  def conform(_spec, _path, _via, _route, _val) do
    {:error, []}
  end
end

defimpl Oath.Spec, for: MapSet do
  def conform(_spec, _path, _via, _route, _val) do
    {:error, []}
  end
end

defimpl Oath.Spec, for: Regex do
  def conform(_spec, _path, _via, _route, _val) do
    {:error, []}
  end
end

defimpl Oath.Spec, for: Range do
  def conform(_spec, _path, _via, _route, _val) do
    {:error, []}
  end
end

defimpl Oath.Spec, for: Date.Range do
  def conform(_spec, _path, _via, _route, _val) do
    {:error, []}
  end
end

defimpl Oath.Spec, for: Any do
  def conform(_spec, _path, _via, _route, _val) do
    {:error, []}
  end
end
