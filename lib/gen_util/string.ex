defmodule GenUtil.String do

  def to_existing_atom(key) when is_binary(key) do
    try do
      String.to_existing_atom(key)
    rescue
      _ in ArgumentError -> key
    end
  end

end