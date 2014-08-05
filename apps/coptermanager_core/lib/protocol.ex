defmodule CoptermanagerCore.Protocol do

  def commands do
    %{:copter_bind     => 0x01,
      :copter_throttle => 0x02,
      :copter_rudder   => 0x03,
      :copter_aileron  => 0x04,
      :copter_elevator => 0x05,
      :copter_led      => 0x06,
      :copter_flip     => 0x07,
      :copter_video    => 0x08,
      :copter_land     => 0x09}
  end

  def types do
    %{"hubsan_x4" => 0x01}
  end

end
