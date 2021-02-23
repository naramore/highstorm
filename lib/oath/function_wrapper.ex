defmodule Oath.FunctionWrapper do
  @moduledoc false
  defstruct function: nil,
            form: nil,
            bindings: []

  @type t :: %__MODULE__{
          function: predicate,
          form: Macro.t(),
          bindings: keyword
        }

  @type predicate :: (any -> boolean)

  @spec new(predicate, Macro.t(), keyword()) :: t
  def new(function, form, bindings \\ []) do
    %__MODULE__{
      function: function,
      form: form,
      bindings: bindings
    }
  end

  @spec wrap(Macro.t(), keyword()) :: Macro.t()
  defmacro wrap(quoted, bindings \\ []) do
    quote do
      Oath.FunctionWrapper.new(
        unquote(quoted),
        unquote(Macro.escape(quoted)),
        unquote(bindings)
      )
    end
  end

  defimpl Oath.Spec do
    alias Oath.ConformError.Problem

    def conform(%@for{function: fun} = wrap, path, via, route, val) do
      case @protocol.Function.conform(fun, path, via, route, val) do
        {:error, [%Problem{pred: ^fun} = p | ps]} -> {:error, [%{p | pred: wrap} | ps]}
        otherwise -> otherwise
      end
    end
  end

  defimpl Inspect do
    def inspect(%@for{form: form, bindings: bindings}, opts) do
      Macro.to_string(form, fn
        {var, _, mod}, string when is_atom(var) and is_atom(mod) ->
          if Keyword.has_key?(bindings, var) do
            Kernel.inspect(
              Keyword.get(bindings, var),
              opts_to_keyword(opts)
            )
          else
            string
          end

        _ast, string ->
          string
      end)
    end

    @spec opts_to_keyword(Inspect.Opts.t()) :: keyword
    defp opts_to_keyword(opts) do
      opts
      |> Map.from_struct()
      |> Enum.into([])
    end
  end
end
