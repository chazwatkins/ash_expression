defmodule AshExpression.Dsl do
  @moduledoc """
  Spark DSL extension for defining expressions.
  """

  @expr %Spark.Dsl.Entity{
    name: :expr,
    target: AshExpression.Dsl.Expr,
    args: [:source_ast],
    schema: [
      source_ast: [
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
    transformers: [
      AshExpression.Transformers.BuildExpressions,
      AshExpression.Transformers.ClassifyExpressions
    ]
end

defmodule AshExpression.Dsl.Expr do
  @moduledoc """
  Represents an expression entity in the DSL.
  """

  defstruct [
    :source_ast,     # Original quoted AST
    :parsed_ir,      # Structured Ref/Call intermediate representation  
    :type,           # :compile_time or :runtime
    :result          # Pre-computed result for compile_time expressions
  ]
end
