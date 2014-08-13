defmodule CoptermanagerCore.Protocol do

  def commands do
    %{:copter_bind       => 0x01,
      :copter_throttle   => 0x02,
      :copter_rudder     => 0x03,
      :copter_aileron    => 0x04,
      :copter_elevator   => 0x05,
      :copter_led        => 0x06,
      :copter_flip       => 0x07,
      :copter_video      => 0x08,
      :copter_emergency  => 0x09,
      :copter_disconnect => 0x0A}
  end

  def types do
    %{"hubsan_x4" => 0x01}
  end

  def statuscodes do
    %{:protocol_ok    => 0x00,
      :protocol_error => 0xFF}
  end

  def inactivity_timer, do: 1*60 # sec
  def max_inactivity_time, do: 10*60 # sec

end
