defmodule CoptermanagerWeb.Config do

  def get(key) do
    Application.get_env(:coptermanager_web, key)
  end
  
end
