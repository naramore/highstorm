defmodule Meddle.Error do
  defexception type: :raise,
               reason: nil,
               stage: nil,
               direction: :enter,
               trace: []

  @type t :: %__MODULE__{
          type: type,
          reason: reason,
          stage: Meddle.id(),
          direction: Meddle.direction(),
          trace: [t]
        }

  @type reason :: term
  @type type :: :raise | :exit | :throw
  @type opt ::
          {:id, Meddle.id()}
          | {:direction, Meddle.direction()}
          | {:type, type}

  @impl Exception
  def message(%__MODULE__{reason: reason}) do
    # TODO: update this...
    inspect(reason)
  end

  @spec new(reason, [opt]) :: t
  def new(reason, opts \\ []) do
    %__MODULE__{
      type: Keyword.get(opts, :type, :raise),
      reason: reason,
      stage: Keyword.get(opts, :id),
      direction: Keyword.get(opts, :direction, :enter)
    }
  end

  @spec from(term, reason, [opt]) :: t
  def from(error, reason, opts \\ [])

  def from(%__MODULE__{} = error, reason, opts) do
    reason
    |> new(opts)
    |> Map.put(:trace, [%{error | trace: []} | error.trace])
  end

  def from(error, reason, opts) do
    reason
    |> new(opts)
    |> Map.put(:trace, [%{error | trace: []}])
  end

  @spec wrap(Meddle.context(), Meddle.error(), type) :: t
  def wrap(context, reason, type \\ :raise) do
    case Meddle.get_error(context) do
      nil ->
        new(reason, gen_opts(context, type))

      error ->
        from(error, reason, gen_opts(context, type))
    end
  end

  @spec gen_opts(Meddle.context(), type) :: [opt]
  defp gen_opts(context, type) do
    [
      type: type,
      id: Meddle.get_stage(context),
      direction: Meddle.get_direction(context)
    ]
  end
end
