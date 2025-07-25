defmodule AshExpressionTest do
  use ExUnit.Case

  describe "structs can represent resource_attribute == true expression" do
    test "Call and Ref structs can represent complex expressions" do
      expected_expression = %AshExpression.Call{
        name: :==,
        args: [
          %AshExpression.Ref{attribute: :resource_attribute, relationship_path: []},
          true
        ],
        operator?: true
      }

      assert expected_expression.name == :==
      assert length(expected_expression.args) == 2

      [left_arg, right_arg] = expected_expression.args
      assert %AshExpression.Ref{attribute: :resource_attribute} = left_arg
      assert right_arg == true
    end
  end

  describe "DSL allows defining expressions with expr/1" do
    defmodule TestModule do
      use AshExpression

      expr(true == false)
      expr(resource_attribute == true)
      expr(status == :active)
    end

    test "module using AshExpression compiles successfully" do
      assert Code.ensure_compiled(TestModule) == {:module, TestModule}
    end

    test "expressions are collected correctly" do
      exprs = AshExpression.Info.exprs(TestModule)
      assert length(exprs) == 3
    end
  end
end
