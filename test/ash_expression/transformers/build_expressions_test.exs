defmodule AshExpression.Transformers.BuildExpressionsTest do
  use ExUnit.Case

  alias AshExpression.{Ref, Call}

  describe "BuildExpressions transformer converts AST to structs" do
    defmodule SimpleExpressions do
      use AshExpression

      expr(status == :active)
      expr(age > 18)
      expr(name != nil)
    end

    test "transforms simple comparisons into Call structs" do
      exprs = AshExpression.Info.exprs(SimpleExpressions)

      # First expression: status == :active
      first_expr = Enum.at(exprs, 0)

      assert Map.has_key?(first_expr, :parsed)

      assert %Call{
               name: :==,
               operator?: true,
               args: [
                 %Ref{attribute: :status, relationship_path: []},
                 :active
               ]
             } = first_expr.parsed

      # Second expression: age > 18
      second_expr = Enum.at(exprs, 1)

      assert %Call{
               name: :>,
               operator?: true,
               args: [
                 %Ref{attribute: :age, relationship_path: []},
                 18
               ]
             } = second_expr.parsed
    end

    test "preserves original AST alongside parsed structure" do
      exprs = AshExpression.Info.exprs(SimpleExpressions)
      first_expr = Enum.at(exprs, 0)

      # Should still have the original quoted expression (structure comparison)
      assert {:==, _meta, [{:status, _, _}, :active]} = first_expr.expression
      # And the parsed version
      assert %Call{} = first_expr.parsed
    end
  end

  describe "complex expressions" do
    defmodule ComplexExpressions do
      use AshExpression

      expr(active? and age >= 21)
      expr(not deleted?)
      expr(category in [:gold, :silver, :bronze])
    end

    test "handles boolean operators" do
      exprs = AshExpression.Info.exprs(ComplexExpressions)

      # First expression: active? and age >= 21
      first_expr = Enum.at(exprs, 0)

      assert %Call{
               name: :and,
               operator?: true,
               args: [
                 %Ref{attribute: :active?},
                 %Call{name: :>=, args: [%Ref{attribute: :age}, 21]}
               ]
             } = first_expr.parsed
    end

    test "handles not operator" do
      exprs = AshExpression.Info.exprs(ComplexExpressions)

      # Second expression: not deleted?
      second_expr = Enum.at(exprs, 1)

      assert %Call{
               name: :not,
               operator?: true,
               args: [%Ref{attribute: :deleted?}]
             } = second_expr.parsed
    end
  end
end
