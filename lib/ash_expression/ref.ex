defmodule AshExpression.Ref do
  @moduledoc """
  Represents a reference to a field or attribute, following the current Ash.Query.Ref pattern.
  """

  defstruct [:attribute, :relationship_path]
end
