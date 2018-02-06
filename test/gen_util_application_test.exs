defmodule GenUtilApplicationTest do
  use ExUnit.Case
  doctest GenUtil.Application

  test "raises when get_env! finds nil a value" do
    assert_raise(RuntimeError, fn ->
      GenUtil.Application.get_env!(:gen_util, :nil_value)
    end)
  end

  test "raises when get_env! finds no value for a key (nil)" do
    assert_raise(RuntimeError, fn ->
      GenUtil.Application.get_env!(:gen_util, :something_else_that_is_not_configured)
    end)
  end

  test "does not raise when get_env! finds a value" do
    assert GenUtil.Application.get_env!(:gen_util, :non_nil_value)
  end

end