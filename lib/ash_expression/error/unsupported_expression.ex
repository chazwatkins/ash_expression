defmodule AshExpression.Error.UnsupportedExpression do
  @moduledoc """
  Error raised when an expression contains unsupported syntax.
  """
  use Splode.Error,
    fields: [:expression, :reason],
    class: :invalid

  def message(%{expression: expression, reason: reason}) do
    """
    Unsupported expression syntax

    Expression: #{inspect(expression)}
    Reason: #{reason}
    """
  end
end
