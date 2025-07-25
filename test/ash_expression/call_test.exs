defmodule AshExpression.CallTest do
  use ExUnit.Case

  describe "AshExpression.Call struct" do
    test "can represent operator calls" do
      call = %AshExpression.Call{
        name: :==,
        args: [:left, :right],
        operator?: true
      }

      assert call.name == :==
      assert call.args == [:left, :right]
      assert call.operator? == true
    end
  end
end
