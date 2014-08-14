defmodule CoptermanagerCore.SerialTest do
  use ExUnit.Case, async: false
  alias CoptermanagerCore.Serial

  test "performance and invalid slot response" do
    :timer.sleep(1500) # wait until arduino is ready
    
    {microsec, result_code} = :timer.tc fn() ->
      Serial.send_command(:serial, 0, 0, 0)
    end

    IO.puts "duration: #{microsec/1000}ms"
    assert result_code == 0xF2 # 8.6-10ms
  end

end
