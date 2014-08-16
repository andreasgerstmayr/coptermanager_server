defmodule CoptermanagerCore.Protocol do

  def commands do
    %{:copter_bind        => 0x01,
      :copter_throttle    => 0x02,
      :copter_rudder      => 0x03,
      :copter_aileron     => 0x04,
      :copter_elevator    => 0x05,
      :copter_led         => 0x06,
      :copter_flip        => 0x07,
      :copter_video       => 0x08,
      :copter_getstate    => 0x09,
      :copter_emergency   => 0x0A,
      :copter_disconnect  => 0x0B,
      :copter_listcopters => 0x0C}
  end

  def types do
    %{"hubsan_x4" => 0x01}
  end

  def statuscodes do
    %{:protocol_ok    => 0x00,

      :protocol_unbound => 0xE0,
      :protocol_bound => 0xE1,

      :protocol_invalid_copter_type => 0xF0,
      :protocol_all_slots_full => 0xF1,
      :protocol_invalid_slot => 0xF2,
      :protocol_value_out_of_range => 0xF3,
      :protocol_emergency_mode_on => 0xF4,
      :protocol_unknown_command => 0xF5}
  end

end
