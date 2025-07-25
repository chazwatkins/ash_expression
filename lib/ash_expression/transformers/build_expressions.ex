defmodule AshExpression.Transformers.BuildExpressions do
  @moduledoc """
  Transformer that builds structured Ref and Call structs from expression AST.

  This transformer has a single responsibility: converting the raw quoted
  expressions captured by the DSL into our internal representation using
  AshExpression.Ref and AshExpression.Call structs.
  """

  use Spark.Dsl.Transformer

  alias AshExpression.{Ref, Call}
  alias AshExpression.Error.UnsupportedExpression

  @impl true
  def transform(dsl_state) do
    dsl_state
    |> Spark.Dsl.Transformer.get_entities([:expressions])
    |> Enum.reduce_while({:ok, dsl_state}, fn expr, {:ok, dsl_state} ->
      try do
        parsed_ir = build_expression(expr.source_ast)
        updated_expr = Map.put(expr, :parsed_ir, parsed_ir)

        {:cont,
         {:ok,
          Spark.Dsl.Transformer.replace_entity(dsl_state, [:expressions], updated_expr, fn e ->
            e == expr
          end)}}
      rescue
        e in [UnsupportedExpression] ->
          {:halt, {:error, e}}
      end
    end)
  end

  # Operators
  defp build_expression({op, _meta, [left, right]}) when op in [:==, :!=, :>, :<, :>=, :<=] do
    %Call{
      name: op,
      operator?: true,
      args: [build_expression(left), build_expression(right)]
    }
  end

  # Boolean operators
  defp build_expression({op, _meta, [left, right]}) when op in [:and, :or] do
    %Call{
      name: op,
      operator?: true,
      args: [build_expression(left), build_expression(right)]
    }
  end

  # Not operator
  defp build_expression({:not, _meta, [expr]}) do
    %Call{
      name: :not,
      operator?: true,
      args: [build_expression(expr)]
    }
  end

  # In operator
  defp build_expression({:in, _meta, [left, right]}) do
    %Call{
      name: :in,
      operator?: true,
      args: [build_expression(left), build_expression(right)]
    }
  end
  
  # Arithmetic operators
  defp build_expression({op, _meta, [left, right]}) when op in [:+, :-, :*, :/] do
    %Call{
      name: op,
      operator?: true,
      args: [build_expression(left), build_expression(right)]
    }
  end

  # Field references (simple atoms)
  defp build_expression({field, _meta, nil}) when is_atom(field) do
    %Ref{
      attribute: field,
      relationship_path: []
    }
  end

  # Literals
  defp build_expression(literal)
       when is_atom(literal) or is_number(literal) or is_binary(literal) do
    literal
  end

  defp build_expression(nil), do: nil
  defp build_expression(true), do: true
  defp build_expression(false), do: false

  # Lists
  defp build_expression(list) when is_list(list) do
    Enum.map(list, &build_expression/1)
  end

  # Catch-all for unsupported expressions
  defp build_expression(ast) do
    raise UnsupportedExpression,
      expression: ast,
      reason: "This expression pattern is not yet supported"
  end
end
