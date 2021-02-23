defmodule Oath.Error do
  @moduledoc false
  defexception reason: nil,
               context: %{}

  @type t :: %__MODULE__{
          reason: any,
          context: map
        }

  @impl Exception
  def message(%__MODULE__{reason: reason}) when is_binary(reason) do
    reason
  end

  def message(%__MODULE__{reason: reason}) do
    inspect(reason)
  end

  @spec new(any, map) :: t
  def new(reason, context \\ %{}) do
    %__MODULE__{
      reason: reason,
      context: context
    }
  end
end

defmodule Oath.ResolveError do
  @moduledoc false
end

defmodule Oath.ConformError do
  @moduledoc false
  alias Oath.Spec

  defexception problems: [],
               spec: nil,
               val: nil

  @type t :: %__MODULE__{
          problems: [problem],
          spec: Oath.t(),
          val: Spec.value()
        }

  @type problem :: __MODULE__.Problem.t()

  @impl Exception
  def message(%__MODULE__{} = error) do
    error.problems
    |> Enum.map(fn p ->
      __MODULE__.Problem.message(p)
    end)
    |> Enum.join("\n")
  end

  @spec new([problem], Oath.t(), Spec.value()) :: t
  def new(problems, spec, val) do
    %__MODULE__{
      problems: problems,
      spec: spec,
      val: val
    }
  end

  defdelegate new_problem(pred, path, via, route, val, reason \\ nil),
    to: __MODULE__.Problem,
    as: :new

  defimpl Inspect do
    @moduledoc false

    import Inspect.Algebra

    def inspect(e, opts) do
      coll = [
        {:prob, e.problems},
        {:spec, e.spec},
        {:val, e.val}
      ]

      fun = fn {k, i}, os -> concat([to_string(k), "=", @protocol.inspect(i, os)]) end
      container_doc("#ConformError<", coll, ">", opts, fun, breaK: :strict, separator: ",")
    end
  end

  defmodule Problem do
    @moduledoc false
    alias Oath.Spec

    defstruct pred: nil,
              path: [],
              via: [],
              route: [],
              val: nil,
              reason: nil

    @type t :: %__MODULE__{
            pred: Oath.t() | nil,
            path: Spec.path(),
            via: Spec.via(),
            route: Spec.route(),
            val: Spec.value(),
            reason: String.Chars.t() | nil
          }

    @spec new(
            Spec.t(),
            Spec.path(),
            Spec.via(),
            Spec.route(),
            Spec.route(),
            String.Chars.t() | nil
          ) :: t
    def new(pred, path, via, route, val, reason \\ nil) do
      %__MODULE__{
        pred: pred,
        path: :lists.reverse(path),
        via: :lists.reverse(via),
        route: :lists.reverse(route),
        val: val,
        reason: reason
      }
    end

    @spec message(t) :: String.t()
    def message(p) do
      p.route
      |> (&if(&1 == [], do: "", else: "in: #{inspect(&1)}")).()
      |> (&"#{&1} val: #{inspect(p.val)} fails").()
      |> (&if(p.via == [], do: &1, else: "#{&1} spec: #{List.last(p.via)}")).()
      |> (&if(p.path == [], do: &1, else: "#{&1} at: #{inspect(p.path)}")).()
      |> (&"#{&1} pred: #{inspect(p.pred)}").()
      |> (&if(is_nil(p.reason), do: &1, else: "#{&1} reason: #{p.reason}")).()
    end

    defimpl Inspect do
      import Inspect.Algebra

      def inspect(problem, opts) do
        coll = [
          {:pred, problem.pred},
          {:path, problem.path},
          {:via, problem.via},
          {:route, problem.route},
          {:val, problem.val},
          {:reason, problem.reason}
        ]

        fun = fn {k, p}, os -> concat([to_string(k), "=", @protocol.inspect(p, os)]) end
        container_doc("#Problem<", coll, ">", opts, fun, break: :flex, separator: ",")
      end
    end
  end
end
