defmodule AshExpression do
  @moduledoc """
  Provides DSL for defining standalone expressions using Spark architecture.
  """

  use Spark.Dsl, default_extensions: [extensions: [AshExpression.Dsl]]
end
