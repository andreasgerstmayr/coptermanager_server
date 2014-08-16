defmodule CoptermanagerCore.Config do

  def get(key) do
    Application.get_env(:coptermanager_core, key)
  end
  
end
