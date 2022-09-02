defmodule ExAudit.Adapters.PatchAdapter do
  @moduledoc ~S"""
  Defines the behaviour for a patch adapter.
  """

  @doc """
  Applies the patch to the given term
  """
  @callback patch(term, term) :: any()
end
