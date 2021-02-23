defmodule Ivy do
  @moduledoc false
  use Boundary, deps: [], exports: []
  # Annex.Repo behaviour for storing / querying from ETS
  # Basis.Database behaviour for querying from ETS
  # Delve behaviour/protocol for 'pull' API
  # Oath for data schema/spec representations
end
