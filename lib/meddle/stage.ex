defmodule Meddle.Stage do
  @moduledoc false
  defstruct id: nil,
            enter: nil,
            leave: nil,
            error: nil

  @type t :: %__MODULE__{
          id: Meddle.id(),
          enter: stage_fun | nil,
          leave: stage_fun | nil,
          error: error_fun | nil
        }

  @type stage_fun :: (Meddle.context() -> Meddle.context())
  @type error_fun :: (Meddle.context(), Meddle.error() -> Meddle.context())
  @type opt ::
          {:id, Meddle.id()}
          | {:enter, stage_fun | nil}
          | {:leave, stage_fun | nil}
          | {:error, error_fun | nil}

  @callback enter(Meddle.context()) :: Meddle.context()
  @callback leave(Meddle.context()) :: Meddle.context()
  @callback error(Meddle.context(), Meddle.error()) :: Meddle.context()

  @spec new([opt]) :: t
  def new(opts \\ []) do
    new(
      Keyword.get(opts, :id),
      Keyword.get(opts, :enter),
      Keyword.get(opts, :leave),
      Keyword.get(opts, :error)
    )
  end

  @spec new(Meddle.id(), stage_fun | nil, stage_fun | nil, error_fun | nil) :: t
  def new(id, enter, leave, error) do
    %__MODULE__{
      id: id,
      enter: enter,
      leave: leave,
      error: error
    }
  end

  defmacro __using__(opts) do
    case Keyword.get(opts, :default) do
      nil ->
        quote do
          @behaviour Meddle.Stage

          @impl Meddle.Stage
          def enter(context), do: context

          @impl Meddle.Stage
          def leave(context), do: context

          @impl Meddle.Stage
          def error(context, error),
            do: Meddle.error(context, error)

          defoverridable enter: 1, leave: 1, error: 2
        end

      default_module ->
        quote do
          @default_module unquote(default_module)
          @behaviour Meddle.Stage

          @impl Meddle.Stage
          def enter(context) do
            @default_module.enter(context)
          end

          @impl Meddle.Stage
          def leave(context) do
            @default_module.leave(context)
          end

          @impl Meddle.Stage
          def error(context, error) do
            @default_module.error(context, error)
          end

          defoverridable enter: 1, leave: 1, error: 2
        end
    end
  end

  defimpl Meddle.Interceptor do
    alias Meddle.Utils

    def invoke(stage, context) do
      Utils.invoke(context, stage, &extract/2)
    end

    def coerce(stage) do
      stage
    end

    @spec extract(Meddle.direction(), @protocol.t) :: function
    defp extract(:enter, stage), do: &stage.enter/1
    defp extract(:leave, stage), do: &stage.leave/1
    defp extract(:error, stage), do: &stage.error/2
  end
end
