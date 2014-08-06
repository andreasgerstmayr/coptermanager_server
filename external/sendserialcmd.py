#!/usr/bin/env python

#import serial
import time
import sys

class Serial:
  def __init__(*args):
    pass

  def write(self, d):
    pass

  def read(self):
    time.sleep(1)
    return bytearray([0x0,2])

def send_command(ser, copterid, command, value):
  data = bytearray([copterid, command, value])
  ser.write(data)

def read_response(ser):
  return ser.read()[0]


if __name__ == '__main__':
  if len(sys.argv) != 6:
    sys.stdout.write("usage: sendserialcmd.py <serialport> <baudrate> <copterid> <command> <value>")
    sys.exit(1)

  serial_port, baudrate, copterid, command, value = sys.argv[1:]
  if not copterid.isdigit() or not command.isdigit() or not value.isdigit():
    sys.stdout.write("only integer values are allowed")
    sys.exit(1)

  ser = Serial('/dev/tty.usbserial', 9600)
  send_command(ser, int(copterid), int(command), int(value))
  response = read_response(ser)
  sys.stdout.write(str(response))
