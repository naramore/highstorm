defmodule Delve.Resolver do
  @moduledoc false

  # TODO: batching (implemented using a more generic transform middleware / interceptor model?)
  #                (or maybe, default to batching? and have single requests be a corner case?)
  # TODO: add params to resolver? (if a resolver can specified required params,
  #                                then this would potentially change planning)
  # TODO: async (perhaps supports the return of a Task.t or [Task.t], or something similar?)
  # TODO: defresolver macro
  # TODO: resolver helpers
  #         - alias_resolver
  #         - equivalence_resolver
  #         - constantly_resolver
  #         - single_attr_resolver
  #         - single_attr_with_env_resolver
  #         - static_table_resolver
  #         - attribute_map_resolver
  #         - attribute_table_resolver
  # TODO: file resolver?
  # TODO: `:ets` resolver?

  defstruct id: nil,
            input: [],
            output: [],
            resolve: nil

  @type t :: %__MODULE__{
          id: id,
          input: input,
          output: output,
          resolve: resolve_fun
        }

  @type id :: Delve.attr()
  @type input :: [Delve.attr()]
  @type output :: [output_attr, ...] | composed_output
  @type output_attr :: Delve.attr() | composed_output
  @type composed_output :: %{required(Delve.attr()) => output}

  @type input_map :: %{optional(Delve.attr()) => any}
  @type output_map :: %{required(Delve.attr()) => [output_map] | any}
  @type resolve_fun :: (input_map, Delve.env() -> output_map)

  @spec new(id, input, output, resolve_fun, keyword) :: t
  def new(id, input, output, resolve, _opts \\ []) do
    %__MODULE__{
      id: id,
      input: input,
      output: output,
      resolve: resolve
    }
  end
end
