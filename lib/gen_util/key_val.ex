defmodule GenUtil.KeyVal do
  @moduledoc """
  Helpers collections of key-value pairs.
  """

  @compile {:inline, fetch: 2, fetch!: 2, get: 2, put: 3, delete: 2, has_key?: 2, replace!: 3}

  @type key :: term()
  @type value :: term()

  @typedoc """
  A pair of values in a 2-tuple.
  """
  @type pair() :: {key(), value()}

  @typedoc """
  A map or list of pairs.
  """
  @type t() :: map() | list(pair)

  @doc """
  Fetches the value for a specific `key` in the given `map`.

  If `map` contains the given `key` then its value is returned in the shape of `{:ok, value}`.

  If `map` doesn't contain `key`, `:error` is returned.

  ## Examples

      iex> KeyVal.fetch(%{a: 1}, :a)
      {:ok, 1}

      iex> KeyVal.fetch(%{"one" => 1}, "one")
      {:ok, 1}

      iex> KeyVal.fetch(%{1 => "one"}, 1)
      {:ok, "one"}

      iex> KeyVal.fetch(%{a: 1}, :b)
      :error

      iex> KeyVal.fetch([a: 1], :a)
      {:ok, 1}

      iex> KeyVal.fetch([{"one", 1}], "one")
      {:ok, 1}

      iex> KeyVal.fetch([{1, "one"}], 1)
      {:ok, "one"}

      iex> KeyVal.fetch([a: 1], :b)
      :error
  """
  @spec fetch(t(), key()) :: {:ok, value()} | :error
  def fetch(props, key) when is_list(props) do
    case :proplists.lookup(key, props) do
      :none -> :error
      {^key, value} -> {:ok, value}
    end
  end

  def fetch(map, key) when is_map(map), do: Map.fetch(map, key)

  @spec fetch!(t(), key()) :: value() | no_return()
  def fetch!(keyval, key) do
    case fetch(keyval, key) do
      {:ok, val} -> val
      :error -> raise %KeyError{key: key, term: keyval}
    end
  end

  @doc """
  Gets the value for the given `key` from the `keyval`.

  If `key` is present in the `keyval` then its value is
  returned. Otherwise, `default` is returned.

  If `default` is not provided, `nil` is used.

  ## Examples
      iex> KeyVal.get(%{}, :a)
      nil

      iex> KeyVal.get(%{a: 1}, :a)
      1
      
      iex> KeyVal.get([a: 1], :b)
      nil
      
      iex> KeyVal.get([a: 1], :b, 3)
      3

  """
  @spec get(t(), key(), value()) :: any()
  def get(keyval, key, default \\ nil) do
    case fetch(keyval, key) do
      {:ok, val} ->
        val

      :error ->
        default
    end
  end

  @doc """
  Returns whether the given `key` exists in the given `keyval`.
  """
  @spec has_key?(t(), key()) :: boolean()
  def has_key?(map, key) when is_map(map), do: Map.has_key?(map, key)
  def has_key(props, key) when is_list(props), do: :proplists.is_defined(key, props)

  @doc """
  Sets a `key` to the given `value`.
  """
  @spec put(t(), key(), value()) :: t()
  def put(map, key, value) when is_map(map) do
    Map.put(map, key, value)
  end

  def put(props, key, value) when is_list(props) do
    [{key, value} | delete(props, key)]
  end

  @doc """
  Returns a list of all the values for the given `key`.
  """
  @spec get_all(t(), key()) :: list(value())
  def get_all(props, key) when is_list(props) do
    props
    |> :proplists.lookup_all(key)
    |> Enum.map(fn {_k, val} -> val end)
  end

  def get_all(map, key) when is_map(map) do
    case Map.fetch(map, key) do
      {:ok, val} -> [val]
      :error -> []
    end
  end

  @doc """
  Deletes the entry in `keyval` for a specific `key`.

  If the `key` does not exist, returns `keyval` unchanged.

  Inlined by the compiler.

  ## Examples

      iex> KeyVal.delete(%{a: 1, b: 2}, :a)
      %{b: 2}

      iex> KeyVal.delete(%{b: 2}, :a)
      %{b: 2}

      iex> KeyVal.delete([a: 1, b: 2], :b)
      [a: 1]

      iex> KeyVal.delete([a: 1, b: 2], :c)
      [a: 1, b: 2]
  """
  def delete(props, key) when is_list(props) do
    :proplists.delete(key, props)
  end

  def delete(map, key) when is_map(map) do
    Map.delete(map, key)
  end

  @doc """
  Puts a value under `key` only if the `key` already exists in `keyval`.

  If `key` is not present in `keyval`, a `KeyError` exception is raised.

  Inlined by the compiler.

  ## Examples

      iex> KeyVal.replace!(%{a: 1, b: 2}, :a, 3)
      %{a: 3, b: 2}

      iex> KeyVal.replace!(%{a: 1}, :b, 2)
      ** (KeyError) key :b not found in: %{a: 1}

      iex> KeyVal.replace!([a: 1, b: 2], :a, 3)
      [a: 3, b: 2]

      iex> KeyVal.replace!([{"one", 1}, {"two", 2}, {"one", 3}], "one", "it was one!")
      [{"one", "it was one!"}, {"two", 2}, {"one", "it was one!"}]

      iex> KeyVal.replace!([a: 1], :b, 2)
      ** (KeyError) key :b not found in: [a: 1]
  """
  @spec replace!(t(), key(), value()) :: t()
  def replace!(map, key, value) when is_map(map) do
    :maps.update(key, value, map)
  end

  def replace!(props, key, value) when is_list(props) do
    do_replace(props, key, value, false)
  catch
    :no_key ->
      raise %KeyError{key: key, term: props}
  end

  defp do_replace([], _key, _value, false) do
    throw(:no_key)
  end

  defp do_replace([], _key, _value, true) do
    []
  end

  defp do_replace([{key, _} | rest], key, value, _seen_key?) do
    [{key, value} | do_replace(rest, key, value, true)]
  end

  defp do_replace([item | rest], key, value, seen_key?) do
    [item | do_replace(rest, key, value, seen_key?)]
  end

  @doc """
  Copies the key-value of `key` from `source` into `dest` or raises.

  Returns `source` with the key-value pair of `key` from `source`.

  Raises if `key` does not exist in `source`.

  ## Examples

      iex> KeyVal.put_copy!(%{}, %{a: "a", b: "b"}, :a)
      %{a: "a"}

      iex> KeyVal.put_copy([], [a: "a", b: "b"], :a)
      [a: "a"]

      iex> KeyVal.put_copy(%{}, %{a: "a", b: "b"}, :c)
      %{}

      iex> KeyVal.put_copy([], [a: "a", b: "b"], :c)
      []

      iex> KeyVal.put_copy(%{a: "z"}, %{a: "a", b: "b"}, :a)
      %{a: "a"}

      iex> KeyVal.put_copy([a: "z"], [a: "a", b: "b"], :a)
      [a: "a"]

  """
  def put_copy(dest, source, key) do
    source
    |> fetch(key)
    |> case do
      {:ok, value} ->
        put(dest, key, value)

      :error ->
        dest
    end
  end

  @doc """
  Copies the key-value of `key` from `source` into `dest` only if
  `key` exists in `source`.

  Returns `source` either unchanged (if the `key` is in source) or
  with the key-value pair of `key` from `source`.

  ## Examples

      iex> KeyVal.put_copy!(%{}, %{a: "a", b: "b"}, :a)
      %{a: "a"}

      iex> KeyVal.put_copy!([], [a: "a", b: "b"], :a)
      [a: "a"]

      iex> KeyVal.put_copy!(%{}, %{a: "a", b: "b"}, :c)
      ** (KeyError) key :c not found in: %{a: "a", b: "b"}

      iex> KeyVal.put_copy!([], [a: "a", b: "b"], :c)
      ** (KeyError) key :c not found in: [a: "a", b: "b"]

      iex> KeyVal.put_copy!(%{a: "z"}, %{a: "a", b: "b"}, :a)
      %{a: "a"}

      iex> KeyVal.put_copy!([a: "z"], [a: "a", b: "b"], :a)
      [a: "a"]
  """
  def put_copy!(dest, source, key) do
    put(dest, key, fetch!(source, key))
  end
end
