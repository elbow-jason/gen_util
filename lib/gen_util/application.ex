defmodule GenUtil.Application do
  def get_env!(app, key) do
    case Application.get_env(app, key) do
      nil ->
        raise %RuntimeError{
          message: "Config error #{inspect app} #{inspect key} must be configured and cannot be nil."
        }
      value ->
        value
    end
  end
end