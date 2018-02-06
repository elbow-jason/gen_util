defmodule GenUtil.Date do
  @moduledoc """
  A few functions for dealing with dates.
  """

  @doc """
  Miles, cups, dates, and politicians. Come on America...
  Here is a function that will parse dates of format `4/12/2014`.
  Probably better to use the Timex library though.

      iex> GenUtil.Date.from_american("06/18/1983")
      {:ok, ~D[1983-06-18]}
      iex> GenUtil.Date.from_american("06-18-1983")
      {:error, :invalid_date_format}
      
  """
  def from_american(date_string) when is_binary(date_string) do
    result =
      date_string
      |> String.split("/")
      |> Enum.map(&Integer.parse/1)
      |> Enum.filter(fn
        {number, ""} when is_integer(number) -> true
        _ -> false
      end)
      |> Enum.map(fn
        {number, ""} -> number
      end)
    case result do
      [month, day, year] -> Date.new(year, month, day)
      _ -> {:error, :invalid_date_format}
    end
  end

end