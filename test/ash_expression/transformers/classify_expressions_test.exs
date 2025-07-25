defmodule AshExpression.Transformers.ClassifyExpressionsTest do
  use ExUnit.Case
  
  describe "ClassifyExpressions transformer" do
    defmodule StaticExpressions do
      use AshExpression
      
      expr(true == false)
      expr(1 + 1 == 2)
      expr("hello" != "world")
      expr(42 > 10)
    end
    
    test "classifies static expressions as compile_time" do
      exprs = AshExpression.Info.exprs(StaticExpressions)
      
      Enum.each(exprs, fn expr ->
        assert expr.type == :compile_time,
          "Expected #{inspect(expr.source_ast)} to be compile_time"
      end)
    end
    
    defmodule RuntimeExpressions do
      use AshExpression
      
      expr(status == :active)
      expr(age > 18)
      expr(name != nil)
      expr(enabled? and visible?)
    end
    
    test "classifies expressions with field references as runtime" do
      exprs = AshExpression.Info.exprs(RuntimeExpressions)
      
      Enum.each(exprs, fn expr ->
        assert expr.type == :runtime,
          "Expected #{inspect(expr.source_ast)} to be runtime"
      end)
    end
    
    defmodule MixedExpressions do
      use AshExpression
      
      expr(status == :active and true)
      expr(age > 0)
      expr(10 < count)
    end
    
    test "classifies mixed expressions as runtime if any field reference exists" do
      exprs = AshExpression.Info.exprs(MixedExpressions)
      
      Enum.each(exprs, fn expr ->
        assert expr.type == :runtime,
          "Expected #{inspect(expr.source_ast)} to be runtime due to field references"
      end)
    end
  end
  
  describe "compile-time evaluation" do
    defmodule CompileTimeEvaluated do
      use AshExpression
      
      expr(2 + 2 == 4)
      expr(not false)
      expr(true and true)
      expr(5 > 3)
    end
    
    test "compile-time expressions can have their results pre-computed" do
      exprs = AshExpression.Info.exprs(CompileTimeEvaluated)
      
      # First expression: 2 + 2 == 4
      first = Enum.at(exprs, 0)
      assert first.result == true
      
      # Second expression: not false
      second = Enum.at(exprs, 1)
      assert second.result == true
      
      # Third expression: true and true
      third = Enum.at(exprs, 2)
      assert third.result == true
      
      # Fourth expression: 5 > 3
      fourth = Enum.at(exprs, 3)
      assert fourth.result == true
    end
  end
end