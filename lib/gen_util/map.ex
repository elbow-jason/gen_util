defmodule GenUtil.Map do

  def to_atom_keys(%{:__struct__ => _} = struct) do
    struct
  end
  def to_atom_keys(%{} = map) do
    map
    |> Enum.map(fn
      {k, v} when is_binary(k) -> {GenUtil.String.to_existing_atom(k), v}
      {k, v} -> {k, v}
    end)
    |> Enum.filter(fn
      {k, _} when is_atom(k) -> true
      _ -> false
    end)
    |> Enum.into(%{})
  end

  def merge!(%{:__struct__ => mod} = struct, %{} = map) do
    try do
      Kernel.struct!(mod)
      Map.merge(struct, struct_safe_map(map, struct)) 
    rescue
      # returning anything that errors above gives ZERO guarantees about it's safety.
      # i.e. a Date struct with the `day` set to nil is an error waiting to happen
      # and not knowing where that error came from.
      _ in ArgumentError -> raise %ArgumentError{
        message: error_message_enforce_keys(mod)
      }
    end 
  end

  def merge(%{:__struct__ => _} = struct, %{} = map) do
    try do
      {:ok, merge!(struct, map)}
    rescue
      _ in ArgumentError -> {:error, :enforced_keys}
    end
  end

  def to_struct!(%{} = map, mod) when is_atom(mod) do
    try do
      Kernel.struct!(mod)
      Kernel.struct!(mod, struct_safe_map(map, mod.__struct__()))
    rescue
      # returning anything that errors above gives ZERO guarantees about it's safety.
      # i.e. a Date struct with the `day` set to nil is an error waiting to happen
      # and not knowing where that error came from.
      
      _ in ArgumentError -> raise %ArgumentError{
        message: error_message_enforce_keys(mod)
      }
    end
  end

  def to_struct(%{} = map, mod) when is_atom(mod) do
    try do
      {:ok, to_struct!(map, mod)}
    rescue
      _ in ArgumentError -> {:error, :enforced_keys}
    end
  end

  defp error_message_enforce_keys(mod) do
    "The module #{mod} is protected with @enforce_keys. Use the module's constructor function(s)."
  end

  defp struct_safe_map(orig_map, the_struct) do
    keys =
      the_struct
      |> Map.from_struct
      |> Map.keys
    orig_map
    |> to_atom_keys
    |> Map.take(keys)
  end


end