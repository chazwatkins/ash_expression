defmodule AshExpression.Error.InvalidExpression do
  @moduledoc """
  Error raised when an expression is malformed or invalid.
  """
  use Splode.Error,
    fields: [:expression, :message],
    class: :invalid

  def message(%{expression: expression, message: message}) do
    """
    Invalid expression

    Expression: #{inspect(expression)}
    #{message}
    """
  end
end
