defmodule CoptermanagerCore.Protocol do

  def commands do
    %{:bind     => 0x01,
      :throttle => 0x02,
      :rudder   => 0x03,
      :aileron  => 0x04,
      :elevator => 0x05,
      :led      => 0x06,
      :flip     => 0x07,
      :video    => 0x08,
      :land     => 0x09}
  end

end
