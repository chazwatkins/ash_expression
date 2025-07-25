defmodule AshExpression.Info do
  @moduledoc """
  Provides introspection functions for AshExpression modules.
  """

  @doc """
  Returns all expressions defined in the given module.
  """
  def exprs(module) do
    Spark.Dsl.Extension.get_entities(module, [:expressions])
  end
end
