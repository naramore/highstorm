defmodule Meddle.Pipe do
  @moduledoc false
  defstruct queue: :queue.new(),
            stack: [],
            direction: :enter

  @type t :: %__MODULE__{
          queue: :queue.queue(),
          stack: list,
          direction: direction
        }

  @type direction :: :enter | :leave

  @spec new(list, direction) :: t
  def new(items \\ [], direction \\ :enter) do
    %__MODULE__{
      queue: :queue.from_list(items),
      direction: direction
    }
  end

  @spec get_direction(t) :: direction
  def get_direction(pipe), do: pipe.direction

  @spec put_direction(t, direction) :: t
  def put_direction(pipe, direction) do
    %{pipe | direction: direction}
  end

  @spec terminate(t) :: t
  def terminate(%{stack: [%__MODULE__{} = ip | s]} = pipe) do
    terminate(%{pipe | stack: [terminate(ip) | s]})
  end

  def terminate(pipe) do
    %{pipe | queue: :queue.new()}
  end

  @spec halt(t) :: t
  def halt(pipe) do
    %{pipe | queue: :queue.new(), stack: []}
  end

  @spec enqueue(t, list) :: t
  def enqueue(pipe, items) do
    Map.update(
      pipe,
      :queue,
      :queue.from_list(items),
      &enqueue_impl(&1, items)
    )
  end

  @spec peek(t) :: {:ok, any} | :error
  def peek(pipe)

  def peek(%{stack: [%__MODULE__{} = ip | _]}) do
    peek(ip)
  end

  def peek(%{direction: :enter, queue: q}) do
    case :queue.peek(q) do
      {:value, x} -> {:ok, x}
      _ -> :error
    end
  end

  def peek(%{stack: [x | _], direction: :leave}) do
    {:ok, x}
  end

  def peek(%{stack: [], direction: :enter}) do
    :error
  end

  @spec next(t) :: {:ok, t} | :error
  def next(%{queue: q, stack: [%__MODULE__{} = ip | s], direction: dir} = pipe) do
    case {next(ip), dir} do
      {{:ok, ip}, _} -> {:ok, %{pipe | stack: [ip | s]}}
      {_, :leave} -> next(%{pipe | queue: :queue.cons(ip, q), stack: s})
      {_, :enter} -> next_impl(pipe)
    end
  end

  def next(pipe) do
    next_impl(pipe)
  end

  @spec previous(t) :: {:ok, t} | :error
  def previous(_pipe) do
    :error
  end

  @spec pop(t) :: {any, t} | nil
  def pop(pipe) do
    with {:ok, pipe} <- next(pipe),
         {:ok, x} <- peek(pipe) do
      {x, pipe}
    else
      _ -> nil
    end
  end

  @spec next_impl(t) :: {:ok, t} | :error
  defp next_impl(pipe) do
    case next_impl_non_recur(pipe) do
      {%__MODULE__{}, pipe} ->
        next(pipe)

      {_, %{stack: [x | xs]} = pipe} when is_list(x) ->
        next(%{pipe | stack: [new(x) | xs]})

      {_, pipe} ->
        {:ok, pipe}

      _ ->
        :error
    end
  end

  @spec next_impl_non_recur(t) :: {any, t} | nil
  defp next_impl_non_recur(%{queue: q, stack: s, direction: :enter} = pipe) do
    case :queue.out(q) do
      {{:value, x}, q} -> {x, %{pipe | queue: q, stack: [x | s]}}
      _ -> nil
    end
  end

  defp next_impl_non_recur(%{queue: q, stack: [x | xs], direction: :leave} = pipe) do
    {x, %{pipe | queue: :queue.cons(x, q), stack: xs}}
  end

  defp next_impl_non_recur(%{stack: [], direction: :leave}), do: nil

  @spec enqueue_impl(:queue.queue() | nil, list) :: :queue.queue()
  defp enqueue_impl(nil, items) do
    enqueue_impl(:queue.new(), items)
  end

  defp enqueue_impl(queue, items) do
    Enum.reduce(items, queue, fn i, q ->
      :queue.in(i, q)
    end)
  end

  defimpl Meddle.Interceptor do
    def invoke(_pipe, context) do
      pipe = Meddle.get_container(context)

      case {@for.pop(pipe), pipe.direction} do
        {{x, pipe}, _} ->
          context
          |> put_pipe(pipe)
          |> (&@protocol.invoke(x, &1)).()
          |> (&invoke(Meddle.get_container(&1), &1)).()

        {nil, :enter} ->
          pipe = %{pipe | direction: :leave}
          invoke(pipe, put_pipe(context, pipe))

        {nil, :leave} ->
          context
      end
    end

    def coerce(pipe) do
      pipe
      |> Map.update!(:stack, &coerce_impl(&1))
      |> Map.update!(:queue, fn queue ->
        queue
        |> :queue.to_list()
        |> coerce_impl()
        |> :queue.from_list()
      end)
    end

    @spec coerce_impl([...]) :: [@protocol.t]
    defp coerce_impl([]), do: []
    defp coerce_impl([h | t]), do: [@protocol.coerce(h) | coerce_impl(t)]

    @spec put_pipe(Meddle.context(), @for.t) :: Meddle.context()
    defp put_pipe(context, pipe) do
      Meddle.update_container(context, fn _ -> pipe end)
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(pipe, opts) do
      coll = [
        :queue.to_list(pipe.queue),
        if(pipe.direction == :enter, do: "->", else: "<-"),
        :lists.reverse(pipe.stack)
      ]

      container_doc("#Pipe|", coll, "|", opts, &inspect_coll/2, break: :flex, separator: "")
    end

    defp inspect_coll(items, opts) when is_list(items) do
      container_doc("[", items, "]", opts, &@protocol.inspect/2, break: :flex, separator: ",")
    end

    defp inspect_coll(item, _opts) when is_binary(item) do
      item
    end

    defp inspect_coll(item, opts) do
      @protocol.inspect(item, opts)
    end
  end
end
