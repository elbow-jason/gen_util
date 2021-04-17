defmodule GenUtil.Map do
  @doc """
  Any map (atom keyed, string keyed, or struct) into an atom keyed map safely.
  This function will discard any non-existing-atom string keys; this function
  does not created new atoms.

      iex> GenUtil.Map.to_atom_keys(%{"name" => "melbo"})
      %{name: "melbo"}
      iex> GenUtil.Map.to_atom_keys(%{"i_sure_hope_this_key_does_not_exist" => false})
      %{}

  """
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

  @doc """
  The raising version of merge/2. See GenUtil.Map.merge/2.
  """
  def merge!(%{:__struct__ => mod} = struct, %{} = map) do
    try do
      Kernel.struct!(mod)
      Map.merge(struct, struct_safe_map(map, struct))
    rescue
      # returning anything that errors above gives ZERO guarantees about it's safety.
      # i.e. a Date struct with the `day` set to nil is an error waiting to happen
      # and not knowing where that error came from.
      _ in ArgumentError ->
        raise %ArgumentError{
          message: error_message_enforce_keys(mod)
        }
    end
  end

  def merge!(%{} = a, %{} = b) do
    Map.merge(a, b)
  end

  @doc """
  Merges a struct with a map/struct only using the 1st argument's fields. This function
  returns `{:ok, <valid_struct_here>}` or `{:error, <reason>}`

      iex> GenUtil.Map.merge(%URI{}, %Date{year: 123, day: 12, month: 1})
      {:ok, %URI{authority: nil, fragment: nil, host: nil, path: nil, port: nil, query: nil, scheme: nil, userinfo: nil}}

      iex> GenUtil.Map.merge(%URI{}, %{host: "123"})
      {:ok, %URI{authority: nil, fragment: nil, host: "123", path: nil, port: nil, query: nil, scheme: nil, userinfo: nil}}

      iex> Date.new(2017, 1, 1) |> elem(1) |> GenUtil.Map.merge(%{year: 123})
      {:error, :enforced_keys}


  """
  def merge(%{:__struct__ => _} = struct, %{} = map) do
    try do
      {:ok, merge!(struct, map)}
    rescue
      _ in ArgumentError -> {:error, :enforced_keys}
    end
  end

  def merge(%{} = a, %{} = b) do
    Map.merge(a, b)
  end

  @doc """
  Turns a map into a struct of the given module.

      iex> GenUtil.Map.to_struct(%{host: "pleb"}, URI)
      {:ok, %URI{authority: nil, fragment: nil, host: "pleb", path: nil, port: nil, query: nil, scheme: nil, userinfo: nil}}

  """
  def to_struct!(%{} = map, mod) when is_atom(mod) do
    try do
      Kernel.struct!(mod)
      Kernel.struct!(mod, struct_safe_map(map, mod.__struct__()))
    rescue
      # returning anything that errors above gives ZERO guarantees about it's safety.
      # i.e. a Date struct with the `day` set to nil is an error waiting to happen
      # and not knowing where that error came from.
      _ in ArgumentError ->
        raise %ArgumentError{
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
      |> Map.from_struct()
      |> Map.keys()

    orig_map
    |> to_atom_keys
    |> Map.take(keys)
  end
end
