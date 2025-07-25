defmodule AshExpression.Dsl.ExprTest do
  use ExUnit.Case
  
  describe "AshExpression.Dsl.Expr struct" do
    defmodule TestExpressions do
      use AshExpression
      
      expr(true == false)
      expr(status == :active)
    end
    
    test "struct contains all expected fields after transformers" do
      exprs = AshExpression.Info.exprs(TestExpressions)
      
      Enum.each(exprs, fn expr ->
        # Should have source AST
        assert expr.source_ast != nil
        
        # Should have parsed IR
        assert expr.parsed_ir != nil
        
        # Should have type classification
        assert expr.type in [:compile_time, :runtime]
        
        # Compile-time expressions should have results
        if expr.type == :compile_time do
          assert expr.result != nil
        end
      end)
    end
    
    test "struct fields have correct types" do
      exprs = AshExpression.Info.exprs(TestExpressions)
      
      [compile_time_expr, runtime_expr] = exprs
      
      # Compile-time expression
      assert compile_time_expr.type == :compile_time
      assert compile_time_expr.result == false
      assert is_tuple(compile_time_expr.source_ast)
      assert is_struct(compile_time_expr.parsed_ir, AshExpression.Call)
      
      # Runtime expression  
      assert runtime_expr.type == :runtime
      assert runtime_expr.result == nil
      assert is_tuple(runtime_expr.source_ast)
      assert is_struct(runtime_expr.parsed_ir, AshExpression.Call)
    end
  end
end