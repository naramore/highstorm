defmodule Meddle.Utils do
  @moduledoc false
  alias Meddle.Error

  @type extractor :: (Meddle.direction(), term -> function | nil)
  @type transform :: (Meddle.context() -> Meddle.context())

  @spec invoke(Meddle.context(), term, extractor) :: Meddle.context()
  def invoke(context, stage, extractor) do
    case Meddle.get_direction(context) do
      :error ->
        safe_invoke(
          extractor.(:error, stage),
          [context, Meddle.get_error(context)],
          &Meddle.put_direction(&1, :leave)
        )

      direction ->
        safe_invoke(extractor.(direction, stage), [context])
    end
  end

  @spec safe_invoke(fun | nil, [any, ...], transform | nil) :: Meddle.context()
  def safe_invoke(f, args, transform \\ nil)
  def safe_invoke(nil, [context | _], _transform), do: context

  def safe_invoke(f, [context | t] = args, transform) do
    if is_nil(transform) do
      apply(f, args)
    else
      apply(f, [transform.(context) | t])
    end
  rescue
    error ->
      wrap_into(context, error, :raise)
  catch
    :exit, reason -> wrap_into(context, reason, :exit)
    value -> wrap_into(context, value, :throw)
  end

  @spec wrap_into(Meddle.context(), Meddle.error(), Error.type()) :: Meddle.context()
  defp wrap_into(context, reason, type) do
    context
    |> Error.wrap(reason, type)
    |> (&Meddle.error(context, &1)).()
  end
end
