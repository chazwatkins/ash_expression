defmodule AshExpression.Call do
  @moduledoc """
  Represents a function call or operator in an expression, following the current Ash.Query.Call pattern.
  """

  defstruct [:name, :args, :operator?]
end
