defmodule AshExpression.Dsl do
  @moduledoc """
  Spark DSL extension for defining expressions.
  """

  @expr %Spark.Dsl.Entity{
    name: :expr,
    target: AshExpression.Dsl.Expr,
    args: [:expression],
    schema: [
      expression: [
        type: :quoted,
        required: true,
        doc: "The expression to define"
      ]
    ]
  }

  @expressions %Spark.Dsl.Section{
    name: :expressions,
    top_level?: true,
    entities: [@expr]
  }

  use Spark.Dsl.Extension,
    sections: [@expressions],
    transformers: [AshExpression.Transformers.BuildExpressions]
end

defmodule AshExpression.Dsl.Expr do
  @moduledoc """
  Represents an expression entity in the DSL.
  """

  defstruct [:expression]
end
