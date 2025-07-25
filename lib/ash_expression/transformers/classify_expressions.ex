defmodule AshExpression.Transformers.ClassifyExpressions do
  @moduledoc """
  Transformer that classifies expressions as compile-time or runtime.
  
  This transformer has a single responsibility: determining whether an
  expression can be evaluated at compile-time (contains only static values)
  or requires runtime evaluation (contains field references).
  
  For compile-time expressions, it also pre-computes the result.
  """
  
  use Spark.Dsl.Transformer
  
  alias AshExpression.{Ref, Call}
  
  @impl true
  def after?(AshExpression.Transformers.BuildExpressions), do: true
  def after?(_), do: false
  
  @impl true
  def transform(dsl_state) do
    dsl_state
    |> Spark.Dsl.Transformer.get_entities([:expressions])
    |> Enum.reduce({:ok, dsl_state}, fn expr, {:ok, dsl_state} ->
      classification = classify_expression(expr.parsed_ir)
      
      updated_expr = 
        expr
        |> Map.put(:type, classification)
        |> maybe_add_compile_time_result(classification)
      
      {:ok, Spark.Dsl.Transformer.replace_entity(
        dsl_state, 
        [:expressions], 
        updated_expr, 
        fn e -> e == expr end
      )}
    end)
  end
  
  # Add compile-time result if expression is compile-time evaluable
  defp maybe_add_compile_time_result(expr, :compile_time) do
    result = evaluate_compile_time(expr.parsed_ir)
    Map.put(expr, :result, result)
  end
  
  defp maybe_add_compile_time_result(expr, :runtime) do
    expr
  end
  
  # Classify expression based on whether it contains field references
  defp classify_expression(parsed) do
    if contains_ref?(parsed) do
      :runtime
    else
      :compile_time
    end
  end
  
  # Check if expression contains any field references
  defp contains_ref?(%Ref{}), do: true
  
  defp contains_ref?(%Call{args: args}) do
    Enum.any?(args, &contains_ref?/1)
  end
  
  defp contains_ref?(list) when is_list(list) do
    Enum.any?(list, &contains_ref?/1)
  end
  
  defp contains_ref?(_), do: false
  
  # Evaluate compile-time expressions
  defp evaluate_compile_time(%Call{name: :==, args: [left, right]}) do
    evaluate_compile_time(left) == evaluate_compile_time(right)
  end
  
  defp evaluate_compile_time(%Call{name: :!=, args: [left, right]}) do
    evaluate_compile_time(left) != evaluate_compile_time(right)
  end
  
  defp evaluate_compile_time(%Call{name: :>, args: [left, right]}) do
    evaluate_compile_time(left) > evaluate_compile_time(right)
  end
  
  defp evaluate_compile_time(%Call{name: :<, args: [left, right]}) do
    evaluate_compile_time(left) < evaluate_compile_time(right)
  end
  
  defp evaluate_compile_time(%Call{name: :>=, args: [left, right]}) do
    evaluate_compile_time(left) >= evaluate_compile_time(right)
  end
  
  defp evaluate_compile_time(%Call{name: :<=, args: [left, right]}) do
    evaluate_compile_time(left) <= evaluate_compile_time(right)
  end
  
  defp evaluate_compile_time(%Call{name: :and, args: [left, right]}) do
    evaluate_compile_time(left) and evaluate_compile_time(right)
  end
  
  defp evaluate_compile_time(%Call{name: :or, args: [left, right]}) do
    evaluate_compile_time(left) or evaluate_compile_time(right)
  end
  
  defp evaluate_compile_time(%Call{name: :not, args: [expr]}) do
    not evaluate_compile_time(expr)
  end
  
  defp evaluate_compile_time(%Call{name: :in, args: [item, list]}) do
    evaluate_compile_time(item) in evaluate_compile_time(list)
  end
  
  # Arithmetic operators
  defp evaluate_compile_time(%Call{name: :+, args: [left, right]}) do
    evaluate_compile_time(left) + evaluate_compile_time(right)
  end
  
  defp evaluate_compile_time(%Call{name: :-, args: [left, right]}) do
    evaluate_compile_time(left) - evaluate_compile_time(right)
  end
  
  defp evaluate_compile_time(%Call{name: :*, args: [left, right]}) do
    evaluate_compile_time(left) * evaluate_compile_time(right)
  end
  
  defp evaluate_compile_time(%Call{name: :/, args: [left, right]}) do
    evaluate_compile_time(left) / evaluate_compile_time(right)
  end
  
  defp evaluate_compile_time(list) when is_list(list) do
    Enum.map(list, &evaluate_compile_time/1)
  end
  
  # Literals evaluate to themselves
  defp evaluate_compile_time(literal), do: literal
end