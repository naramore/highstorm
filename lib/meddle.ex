defmodule Meddle do
  @moduledoc false
  use Boundary, deps: [], exports: []
  alias Meddle.{Interceptor, Pipe, Stage}

  # TODO: parallel interceptor?

  # TODO: middleware for timeout/2, requires/2, provides/2, satisfies/2
  #       these may belong in MeddleUtils (or something similar), as they should require `Oath`

  @container :__pipe__
  @error :__error__

  @type container :: Pipe.t()
  @type t :: Interceptor.t()
  @type id :: term
  @type error :: term
  @type direction :: Pipe.direction() | :error
  @type context :: %{
          :__pipe__ => container | nil,
          :__error__ => error | nil,
          optional(any) => any
        }

  @spec start(context) :: context
  def start(context) do
    Map.merge(
      %{
        @container => Pipe.new(),
        @error => nil
      },
      context
    )
  end

  @spec execute(context) :: {:ok, context} | {:error, error}
  def execute(context) do
    context
    |> start()
    |> Map.get(@container)
    |> Interceptor.invoke(context)
    |> case do
      %{@error => nil} = context -> {:ok, context}
      %{@error => reason} -> {:error, reason}
    end
  end

  @spec execute(context, [t]) :: {:ok, context} | {:error, error}
  def execute(context, interceptors) do
    context
    |> start()
    |> enqueue(interceptors)
    |> execute()
  end

  @spec error(context, error) :: context
  def error(context, err) do
    context
    |> Map.put(@error, err)
    |> put_direction(:leave)
  end

  @spec stage(context, [Stage.opt()]) :: context
  def stage(context, opts \\ []) do
    enqueue(context, [Stage.new(opts)])
  end

  @spec terminate(context) :: context
  def terminate(context) do
    Map.update(context, @container, Pipe.new(), &Pipe.terminate/1)
  end

  @spec halt(context) :: context
  def halt(context) do
    Map.update(context, @container, Pipe.new(), &Pipe.halt/1)
  end

  @spec enqueue(context, [t]) :: context
  def enqueue(context, interceptors) do
    Map.update(context, @container, Pipe.new(interceptors), &Pipe.enqueue(&1, interceptors))
  end

  @spec transform(Stage.stage_fun(), (context, any -> context)) :: Stage.stage_fun()
  def transform(f, g) do
    fn context ->
      g.(context, f.(context))
    end
  end

  @spec take_in(Stage.stage_fun(), path :: [term, ...]) :: Stage.stage_fun()
  def take_in(f, path) do
    fn context ->
      f.(get_in(context, path))
    end
  end

  @spec return_at(Stage.stage_fun(), path :: [term, ...]) :: Stage.stage_fun()
  def return_at(f, path) do
    transform(f, &put_in(&1, path, &2))
  end

  @spec whenever(Stage.stage_fun(), (context -> boolean)) :: Stage.stage_fun()
  def whenever(f, pred) do
    fn context ->
      if pred.(context) do
        f.(context)
      else
        context
      end
    end
  end

  @spec lens(Stage.stage_fun(), path :: [term, ...]) :: Stage.stage_fun()
  def lens(f, path) do
    f
    |> take_in(path)
    |> return_at(path)
  end

  @spec discard(Stage.stage_fun()) :: Stage.stage_fun()
  def discard(f) do
    transform(f, fn context, _ -> context end)
  end

  @doc false
  @spec coerce(context) :: context
  def coerce(context) do
    Map.update!(context, @container, &Interceptor.coerce/1)
  end

  @doc false
  @spec get_stage(context) :: id | nil
  def get_stage(%{@container => container}) do
    case Pipe.peek(container) do
      {:ok, %{id: id}} -> id
      _ -> nil
    end
  end

  @doc false
  @spec get_direction(context) :: direction
  def get_direction(%{@error => nil, @container => container}) do
    Pipe.get_direction(container)
  end

  def get_direction(_) do
    :error
  end

  @doc false
  @spec put_direction(context, Pipe.direction()) :: context
  def put_direction(context, direction) do
    Map.update!(context, @container, &Pipe.put_direction(&1, direction))
  end

  @doc false
  @spec get_error(context) :: error | nil
  def get_error(context) do
    Map.get(context, @error)
  end

  @doc false
  @spec remove_error(context) :: context
  def remove_error(context) do
    Map.put(context, @error, nil)
  end

  @doc false
  @spec get_container(context) :: container
  def get_container(%{@container => container}), do: container

  @doc false
  @spec update_container(context, (container -> container)) :: context
  def update_container(context, fun) do
    Map.update!(context, @container, fun)
  end
end
