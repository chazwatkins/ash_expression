defmodule AshExpression.RefTest do
  use ExUnit.Case

  describe "AshExpression.Ref struct" do
    test "can represent field references" do
      ref = %AshExpression.Ref{attribute: :resource_attribute, relationship_path: []}

      assert ref.attribute == :resource_attribute
      assert ref.relationship_path == []
    end
  end
end
